defmodule ExCdrPusher.HSqlite do

  require Logger

  def sqlite_get_cdr() do
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

  # def sqlite_create_fields() do
  #   case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
  #     {:ok, db} ->
  #       Sqlitex.query(db, "ALTER TABLE cdr ADD COLUMN imported INTEGER DEFAULT 0;")
  #       Sqlitex.query(db, "ALTER TABLE cdr ADD COLUMN pg_cdr_id INTEGER DEFAULT 0;")
  #       Sqlitex.query(db, "CREATE INDEX IF NOT EXISTS cdr_imported ON cdr (imported);")
  #     {:error, reason} ->
  #       Logger.error reason
  #       {:error}
  #   end
  # end

  # Mark those CDRs as imported to not fetch them twice
  def sqlite_update_many_cdr(cdrs) do
    Logger.debug "Mark CDRs: #{length(cdrs)}"
    ids = Enum.map(cdrs, fn(x) -> x[:rowid] end)
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