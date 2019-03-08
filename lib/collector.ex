defmodule Collector do
  use GenServer
  require Logger
  alias ExCdrPusher.HSqlite

  @moduledoc """
  This module implement the heartbeat to retrieve the CDRs from the SQLite
  and then push them to the Genserver in charge of sending the CDRs to
  PostgreSQL
  """

  # @tick_freq 100 # 100ms
  @tick_freq Application.fetch_env!(:excdr_pusher, :tick_frequency)

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    log_version()

    Logger.info(
      "[init] start collecting CDRs from " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    )

    # Removed as we do it during the installation...
    # HSqlite.sqlite_create_fields()
    # 0.1 sec
    Process.send_after(self(), :timeout_tick, @tick_freq)
    # 1 sec
    Process.send_after(self(), :timeout_1sec, 1 * 1000)
    {:ok, state}
  end

  def log_version do
    {:ok, vsn} = :application.get_key(:excdr_pusher, :vsn)
    app_version = List.to_string(vsn)
    {_, _, ex_ver} = List.keyfind(:application.which_applications(), :elixir, 0)
    erl_version = :erlang.system_info(:otp_release)

    Logger.error(
      "[starting] excdr_pusher (app_version:#{app_version} - " <>
        "ex_ver:#{ex_ver} - erl_version:#{erl_version})"
    )

    Logger.error("[config] tick_freq:#{@tick_freq}")
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
    Process.send_after(self(), :timeout_tick, @tick_freq)

    if File.regular?(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      start_import()
    else
      Logger.error(
        "Sqlite database not found: " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
      )
    end

    # current_date = :os.timestamp |> :calendar.now_to_datetime
    # Logger.debug "#{inspect current_date}"
  end

  defp start_import do
    # HSqlite.count_cdr()
    {:ok, cdr_list} = HSqlite.fetch_cdr()
    HSqlite.mark_cdr_imported(cdr_list)
    # Send CDRs to PostgreSQL
    PusherPG.sync_push(cdr_list)
  end

  # defp start_pushing_cdr(cdr_list) do
  #   # Send CDRs to PostgreSQL
  #   PusherPG.push(cdr_list)
  #   # Send CDRs to InfluxDB
  #   # PushInfluxDB.push(cdr_list)
  # end

  # def push_singlecdr(result) do
  #   case result do
  #     {:ok, cdrs} ->
  #       results = Enum.map(cdrs, &PusherPG.push/1)
  #       if Enum.any?(results, fn(x) -> x != :ok end) do
  #         # Mark them all not imported
  #         Logger.error "Detected errors on import..."
  #         Logger.error "Error results: #{inspect results}"
  #       end
  #   end
  # end

  # Not used at the moment, it was used by push_pg to update status on insert
  # def handle_cast({:pg_cdr_ok, rowid, pg_cdr_id}, state) do
  #   HSqlite.update_sqlite_cdr_ok(rowid, pg_cdr_id)
  #   {:noreply, state}
  # end

  # def handle_cast({:pg_cdr_error, rowid}, state) do
  #   HSqlite.update_sqlite_cdr_error(rowid)
  #   {:noreply, state}
  # end

  # # Async mark CDR Ok
  # def update_cdr_ok(rowid, pg_cdr_id) do
  #   GenServer.cast(__MODULE__, {:pg_cdr_ok, rowid, pg_cdr_id})
  # end

  # # Async mark CDR error
  # def update_cdr_error(rowid) do
  #   GenServer.cast(__MODULE__, {:pg_cdr_error, rowid})
  # end
end
