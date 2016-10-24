defmodule Collector do
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Logger.debug "[init] we will collect cdrs information from " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    sqlite_create_fields()
    Process.send_after(self(), :timeout_1, 1 * 1000) # 1 sec
    {:ok, state}
  end

  def handle_info(:timeout_1, state) do
    schedule_task() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_task() do
    Process.send_after(self(), :timeout_1, 1 * 1000) # 1 sec
    if File.regular?(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      fetch_cdr()
    else
      Logger.error "Sqlite database not found: " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    end
    # current_date = :os.timestamp |> :calendar.now_to_datetime
    # Logger.debug "#{inspect current_date}"
  end

  defp fetch_cdr() do
    cdrs = sqlite_get_cdr()
    case cdrs do
      {:error, {:sqlite_error, reason}} ->
        Logger.error reason
      {:ok, []} ->
        Logger.info "cdrs is empty []"
      {:ok, _} ->
        sqlite_update_many_cdr(cdrs)
        Logger.info "CDR to PG: -*****************************************************-"
        push_cdr(cdrs)
    end
  end

  def push_cdr(result) do
    case result do
      {:ok, cdrs} ->
        results = Enum.map(cdrs, &Pusher.push/1)
        if Enum.any?(results, fn(x) -> x != :ok end) do
          # Mark them all not imported
          Logger.error "Detected errors on import..."
          Logger.error "Error results: #{inspect results}"
        end
    end
  end

  defp sqlite_get_cdr() do
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        fetchsql = "SELECT OID, * FROM cdr WHERE imported=0 ORDER BY OID DESC LIMIT ?;"
        # IO.puts "fetchsql:" <> fetchsql
        Sqlitex.query(db, fetchsql, bind: [Application.fetch_env!(:excdr_pusher, :amount_cdr_fetch)])
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

  defp sqlite_create_fields() do
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, "ALTER TABLE cdr ADD COLUMN imported INTEGER DEFAULT 0;")
        Sqlitex.query(db, "ALTER TABLE cdr ADD COLUMN pg_cdr_id INTEGER DEFAULT 0;")
        Sqlitex.query(db, "CREATE INDEX IF NOT EXISTS cdr_imported ON cdr (imported);")
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

  # Mark those CDRs as imported to not fetch them twice
  defp sqlite_update_many_cdr(cdrs) do
    case cdrs do
      {:ok, listcdr} ->
        Logger.debug "Mark CDRs: #{length(listcdr)}"
        ids = Enum.map(listcdr, fn(x) -> x[:rowid] end)
        questmarks = Enum.map(ids, fn(x) -> "?" end) |> Enum.join(", ")
        sql = "UPDATE cdr SET imported=1 WHERE imported=0 AND OID IN (" <> questmarks <> ")"
        # IO.puts sql
        case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
          {:ok, db} ->
            Sqlitex.query(db, sql, bind: ids)
          {:error, reason} ->
            Logger.error reason
            {:error}
        end
    end
  end

  # Async mark CDR Ok
  def update_cdr_ok(rowid, pg_cdr_id) do
    GenServer.cast(__MODULE__, {:pg_cdr_ok, rowid, pg_cdr_id})
  end

  def handle_cast({:pg_cdr_ok, rowid, pg_cdr_id}, state) do
    update_sqlite_cdr_ok(rowid, pg_cdr_id)
    {:noreply, state}
  end

  def update_sqlite_cdr_ok(rowid, pg_cdr_id) do
    Logger.info "CDR imported rowid:#{rowid} - pg_cdr_id:#{pg_cdr_id}"
    sql = "UPDATE cdr SET imported=1, pg_cdr_id=? WHERE OID=?"
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, sql, bind: [pg_cdr_id, rowid])
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

  # Async mark CDR error
  def update_cdr_error(rowid) do
    GenServer.cast(__MODULE__, {:pg_cdr_error, rowid})
  end

  def handle_cast({:pg_cdr_error, rowid}, state) do
    update_sqlite_cdr_error(rowid)
    {:noreply, state}
  end

  def update_sqlite_cdr_error(rowid) do
    Logger.debug "CDR not imported rowid:#{rowid}"
    sql = "UPDATE cdr SET imported=0 WHERE OID=?"
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, sql, bind: rowid)
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

end
