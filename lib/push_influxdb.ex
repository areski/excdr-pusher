defmodule PushInfluxDB do
  use GenServer
  require Logger

  alias ExCdrPusher.InConnection, as: InfluxCon

  @moduledoc """
  Genserver that push CDRs to InfluxDB, this module is not used at the moment
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # Insert CDR in batch
  def insert_cdr(cdr_list) do
    series = Enum.map(cdr_list, &build_series/1)
    # IO.inspect series
    res = series |> InfluxCon.write([async: true, precision: :nanoseconds])
    case res do
      :ok ->
        series_ct = series |> Enum.count
        Logger.info "wrote #{series_ct} points"
      {:error, :econnrefused} ->
        Logger.error "error writing points"
      _  ->
        Logger.error "error writing points: #{inspect series}"
    end

    {:ok}
  end

  # From Erlang 18:
  def convert_start_uepoch_nano(""), do:
    :os.system_time(:milli_seconds) * 1_000_000
  # From Erlang 19.1:
  # def convert_start_uepoch_nano(""), do:
  #   :os.system_time(:millisecond) * 1_000_000

  def convert_start_uepoch_nano(value) do
    :rand.seed(:exs1024, :os.timestamp)
    # add random 3 digits for precision
    [extranum] = Enum.take_random(100..999, 1)
    value * 1000 + extranum
  end

  def build_series(data) do
    ntime = convert_start_uepoch_nano(data[:start_uepoch])
    Logger.info "ntime: #{ntime}"

    serie = %CDRDurationSeries{}
    serie = %{serie | timestamp: ntime}
    serie = %{serie | tags: %{serie.tags | campaign_id: data[:campaign_id]}}
    serie = %{serie | fields: %{serie.fields | value: data[:billsec]}}
    serie
    # ???
    # Build all series and return them all:
    # CDRBilledDurationSeries, CDRCallCostSeries, CDRHangupCauseSeries,
    # CDRHangupCauseQ850Series

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
