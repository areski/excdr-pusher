defmodule PushInfluxDB do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  # Insert CDR in batch
  def insert_cdr(cdr_list) do
    series = Enum.map(cdr_list, &build_series/1)
    # IO.inspect series
    case series |> ExCdrPusher.InConnection.write([async: true, precision: :seconds]) do
      :ok ->
        Logger.info "wrote " <> (Enum.count(series) |> Integer.to_string) <> " points"
      {:error, :econnrefused} ->
        Logger.error "error writing points"
      _  ->
        Logger.error "error writing points: #{inspect series}"
    end

    {:ok}
  end

  def build_series(data) do
    IO.inspect data[:start_stamp]
    serie = %CDRDurationSeries{}
    serie = %{ serie | tags: %{ serie.tags | campaign_id: data[:campaign_id] }}
    serie = %{ serie | fields: %{ serie.fields | value: data[:billsec] }}
    serie
    IO.inspect serie

    # ???
    # Build all series and return them all:
    # CDRBilledDurationSeries, CDRCallCostSeries, CDRHangupCauseSeries, CDRHangupCauseQ850Series

  end

  # Async push CDRs
  def push(cdr) do
    GenServer.cast(__MODULE__, {:push_cdr, cdr})
  end

  def handle_cast({:push_cdr, cdr}, state) do
    # Insert the CDR
    {:ok} = insert_cdr(cdr)
    {:noreply, state}
  end

end