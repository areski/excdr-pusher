defmodule Collector do
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Logger.debug "[init] we will collect cdrs information from " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    # Create field
    add_cdr_field_imported()
    Process.send_after(self(), :timeout_1, 1 * 1000) # 1 sec
    {:ok, state}
  end

  def handle_info(:timeout_1, state) do
    # Do the work you desire here
    schedule_task() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_task() do
    # IO.puts "schedule_task..."
    Process.send_after(self(), :timeout_1, 1 * 1000) # 1 sec

    if File.regular?(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      # Dispatch Task
      task_fetch_cdrs()
    else
      Logger.error "Sqlite database not found: " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    end

    # current_date = :os.timestamp |> :calendar.now_to_datetime
    # Logger.debug "#{inspect current_date}"
  end

  defp task_fetch_cdrs() do
    cdrs = get_cdrs()
    case cdrs do
      {:error, {:sqlite_error, reason}} ->
        Logger.error reason
      {:ok, []} ->
        Logger.info "cdrs is empty []"
      {:ok, _} ->
        # Mark those CDRs as imported to not fetch them twice
        many_cdr_imported(cdrs)
        Logger.info "CDR to PG..."
        Logger.info "-*****************************************************-"
        push_cdrs(cdrs)
    end
  end

  def push_cdrs(result) do
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

  defp get_cdrs() do
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

  defp add_cdr_field_imported() do
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

  defp many_cdr_imported(cdrs), do: many_cdr_update(cdrs, 1)

  # mark CDRs as not imported, used when errors occur on the push CDRs to PG
  defp many_cdr_notimported(cdrs), do: many_cdr_update(cdrs, 0)

  defp querymarkcdr(imported) do
    case imported do
     1 -> "UPDATE cdr SET imported=1 WHERE imported=0"
     0 -> "UPDATE cdr SET imported=0 WHERE imported=1"
   end
  end

  # Genereric function to mark CDRs
  defp many_cdr_update(cdrs, imported) do
    case cdrs do
      {:ok, listcdr} ->
        Logger.debug "Mark CDRs: #{length(listcdr)}"
        ids = Enum.map(listcdr, fn(x) -> x[:rowid] end)
        questmarks = Enum.map(ids, fn(x) -> "?" end) |> Enum.join(", ")
        updatesql = querymarkcdr(imported) <> " AND OID IN (" <> questmarks <> ")"
        # IO.puts updatesql
        case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
          {:ok, db} ->
            Sqlitex.query(db, updatesql, bind: ids)
          {:error, reason} ->
            Logger.error reason
            {:error}
        end
    end
  end

  # Async mark CDR Ok
  def mark_cdr_pg_cdr_id(rowid, pg_cdr_id) do
    GenServer.cast(__MODULE__, {:mark_cdr_error, rowid, pg_cdr_id})
  end

  def handle_cast({:mark_cdr_error, rowid, pg_cdr_id}, state) do
    cdr_imported(rowid, pg_cdr_id)
    {:noreply, state}
  end

  def cdr_imported(rowid, pg_cdr_id) do
    Logger.info "CDR imported rowid:#{rowid} - pg_cdr_id:#{pg_cdr_id}"
    updatesql = "UPDATE cdr SET imported=1, pg_cdr_id=? WHERE OID=?"
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, updatesql, bind: [pg_cdr_id, rowid])
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

  # Async mark CDR error
  def mark_cdr_error(rowid) do
    GenServer.cast(__MODULE__, {:mark_cdr_error, rowid})
  end

  def handle_cast({:mark_cdr_error, rowid}, state) do
    cdr_notimported(rowid)
    {:noreply, state}
  end

  def cdr_notimported(rowid) do
    Logger.debug "CDR not imported rowid:#{rowid}"
    updatesql = "UPDATE cdr SET imported=0 WHERE OID=?"
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, updatesql, bind: rowid)
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

end
