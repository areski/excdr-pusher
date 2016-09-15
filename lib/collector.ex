defmodule Collector do
  use GenServer
  require Logger

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def init(state) do
    Logger.debug "[init] we will collect cdrs information from " <> Application.fetch_env!(:excdr_pusher, :sqlite_db)
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
    Process.send_after(self(), :timeout_1, 6 * 1000) # 6 seconds

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
        Logger.info "pushing CDRs... TODO"
        IO.inspect cdrs
        # TODO
        # Pusher.push_cdrs(cdrs)
    end
  end

  defp get_cdrs() do
    case Sqlitex.open(Application.fetch_env!(:excdr_pusher, :sqlite_db)) do
      {:ok, db} ->
        Sqlitex.query(db, "SELECT * FROM cdr;")
      {:error, reason} ->
        Logger.error reason
        {:error}
    end
  end

end