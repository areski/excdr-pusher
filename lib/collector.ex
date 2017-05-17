defmodule Collector do
  use GenServer
  require Logger
  alias ExCdrPusher.HSqlite

  @tick_freq 100 # 100ms

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    log_version()
    Logger.info "[init] start collecting CDRs from " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    # Removed as we do it during the installation...
    # HSqlite.sqlite_create_fields()
    Process.send_after(self(), :timeout_1, @tick_freq) # 0.1 sec
    # Process.send_after(self(), :timeout_1sec, 1 * 1000) # 1 sec
    {:ok, state}
  end

  def log_version() do
    {:ok, vsn} = :application.get_key(:excdr_pusher, :vsn)
    app_version = List.to_string(vsn)
    {:elixir, _, ex_version} = List.keyfind(:application.which_applications, :elixir, 0)
    Logger.info "[starting] excdr_pusher (app_version:#{app_version} - ex_version:#{ex_version})"
  end

  def handle_info(:timeout_1, state) do
    schedule_task() # Reschedule once more
    {:noreply, state}
  end

  # def handle_info(:timeout_1sec, state) do
  #   Process.send_after(self(), :timeout_1sec, 1 * 1000) # 1 sec
  #   {:noreply, state}
  # end

  defp schedule_task() do
    Process.send_after(self(), :timeout_1, @tick_freq) # 0.1 sec
    if File.regular?(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      start_import()
    else
      Logger.error "Sqlite database not found: " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
    end
    # current_date = :os.timestamp |> :calendar.now_to_datetime
    # Logger.debug "#{inspect current_date}"
  end

  defp start_import() do
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

  # Not used at the moment, as it was used by push_pg to update status on insert
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
