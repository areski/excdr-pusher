defmodule Pusher do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def push_cdrs(result) do
    Logger.debug "pushing cdrs..."
    case result do
      {:ok, cdrs} ->
        write_cdrs(cdrs)
    end
  end

  def write_cdrs(cdrs) do
    # series = Enum.map(chan_result, fn(x) -> parse_channels x end)
    # IO.inspect series
    IO.puts "write_cdrs"
    IO.inspect cdrs
    # Write to PostgreSQL

    # Error to write CDRs
    Collector.rollback_cdr_imported({:ok, cdrs})
  end


  def push(item) do
    GenServer.cast(__MODULE__, {:push, item})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def lookup(item) do
    :error
  end


  # Server (callbacks)
  # Sync
  def handle_call(:pop, _from, []) do
    {:reply, [], []}
  end

  def handle_call(:pop, _from, [h | t]) do
    {:reply, h, t}
  end

  # def handle_call(request, from, state) do
  #   # Call the default implementation from GenServer
  #   super(request, from, state)
  # end

  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end

end