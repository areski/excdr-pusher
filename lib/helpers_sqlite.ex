defmodule ExCdrPusher.HSqlite do
  require Logger
  alias Application, as: App

  @moduledoc """
  This module contains method to communicate with SQLite CDRs storage.
  """

  # Found CDRs not imported
  def fetch_cdr do
    case Sqlitex.open(App.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        fetchsql = "SELECT OID, * FROM cdr WHERE imported=0 ORDER BY OID DESC LIMIT ?;"
        cdrs = Sqlitex.query(db, fetchsql, bind: [App.fetch_env!(:excdr_pusher, :amount_cdr_fetch)])
        Sqlitex.close(db)
        cdrs

      {:error, reason} ->
        Logger.error(reason)
        {:error}
    end
  end

  # Mark those CDRs as imported to not fetch them twice
  def mark_cdr_imported(cdrs) do
    Logger.debug(fn -> "Mark CDRs: #{length(cdrs)}" end)

    ids = Enum.map(cdrs, fn x -> x[:rowid] end)
    questmarks = ids |> Enum.map(fn _ -> "?" end) |> Enum.join(", ")
    sql = "UPDATE cdr SET imported=1 WHERE OID IN (" <> questmarks <> ")"
    # IO.puts sql
    case Sqlitex.open(App.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, sql, bind: ids)
        Sqlitex.close(db)

      {:error, reason} ->
        Logger.error(reason)
        {:error}
    end
  end

  # Sqlitex.Server will not detect if the DB has an issue or corruption

  # # Found CDRs not imported
  # def fetch_cdr do
  #   Sqlitex.Server.query(
  #     Sqlitex.DB,
  #     "SELECT OID, * FROM cdr WHERE imported=0 ORDER BY OID DESC LIMIT ?;",
  #     bind: [App.fetch_env!(:excdr_pusher, :amount_cdr_fetch)]
  #   )
  # end

  # # Mark those CDRs as imported to not fetch them twice
  # def mark_cdr_imported(cdrs) do
  #   Logger.debug(fn -> "Mark CDRs: #{length(cdrs)}" end)
  #   ids = Enum.map(cdrs, fn x -> x[:rowid] end)
  #   questmarks = ids |> Enum.map(fn _ -> "?" end) |> Enum.join(", ")
  #   sql = "UPDATE cdr SET imported=1 WHERE OID IN (" <> questmarks <> ")"
  #   Sqlitex.Server.query(Sqlitex.DB, sql, bind: ids)
  # end
end
