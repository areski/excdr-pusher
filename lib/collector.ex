defmodule Collector do
  use GenServer
  require Logger
  alias ExCdrPusher.HSqlite

  @moduledoc """
  This module implement the heartbeat to retrieve the CDRs from the SQLite
  and then push them to the Genserver in charge of sending the CDRs to
  PostgreSQL
  """

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Logger.info(
      "[init] start collecting CDRs from " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    )

    # 0.1 sec
    Process.send_after(
      self(),
      :timeout_tick,
      Application.fetch_env!(:excdr_pusher, :tick_frequency)
    )

    # 1 sec
    Process.send_after(self(), :timeout_1sec, 1 * 1000)
    {:ok, state}
  end

  def handle_info(:timeout_tick, state) do
    # Reschedule once more
    schedule_task()
    {:noreply, state}
  end

  def handle_info(:timeout_1sec, state) do
    Logger.warn("(check collector alive) 1s heartbeat")
    # 1 sec
    Process.send_after(self(), :timeout_1sec, 1 * 1000)
    {:noreply, state}
  end

  defp schedule_task do
    # 0.1 sec
    Process.send_after(
      self(),
      :timeout_tick,
      Application.fetch_env!(:excdr_pusher, :tick_frequency)
    )

    if File.regular?(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      start_import()
    else
      Logger.error(
        "Sqlite database not found: " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
      )
    end
  end

  defp start_import do
    # HSqlite.count_cdr()
    {:ok, cdr_list} = HSqlite.fetch_cdr()
    HSqlite.mark_cdr_imported(cdr_list)
    # Send CDRs to PostgreSQL
    PusherPG.sync_push(cdr_list)
  end
end
