defmodule Pusher do
  use GenServer
  require Logger

  alias ExCdrPusher.Repo
  alias ExCdrPusher.CDR
  alias ExCdrPusher.Utils

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
    # Write to PostgreSQL
    results = Enum.map(cdrs, fn(x) -> insert_cdr(x) end)
  end

  def insert_cdr(cdr) do
    {billed_duration, cdrdate, legtype, amd_status, nibble_total_billed} = sanitize_cdr_data(cdr)
    disposition = Utils.get_disposition(cdr[:hangup_cause])
    hangup_cause_q850 = Utils.convertintdefault(cdr[:hangup_cause_q850], 0)
    user_id = sanitize_user_id(cdr[:user_id])

    newcdr = %CDR{callid: cdr[:uuid], callerid: cdr[:caller_id_number], phone_number: cdr[:destination_number], starting_date: cdrdate, duration: cdr[:duration], billsec: cdr[:billsec], disposition: disposition, hangup_cause: cdr[:hangup_cause], hangup_cause_q850: hangup_cause_q850, leg_type: legtype, amd_status: amd_status, callrequest: cdr[:callrequest_id], used_gateway_id: cdr[:used_gateway_id], user_id: user_id, billed_duration: billed_duration, call_cost: nibble_total_billed}
    result = Repo.insert!(newcdr)

    case result do
      %CDR{id: pg_cdr_id} ->
        Logger.debug "PG_CDR_ID -> #{pg_cdr_id}"
        Collector.mark_cdr_imported(cdr[:rowid], pg_cdr_id)
      {:error, err} ->
        Logger.error err
      _ ->
        Logger.error "Pusher: something unexpected"
    end

  end

  # Sanitize User ID
  defp sanitize_user_id(user_id) when user_id=="" do
    1
  end
  defp sanitize_user_id(user_id), do: user_id

  # prepare & sanitize CDR data
  defp sanitize_cdr_data(cdr) do
    # We will clean and sanitize some field coming from Sqlite and prepare them PostgreSQL
    billed_duration = Utils.calculate_billdur(cdr[:billsec], cdr[:nibble_increment])
    {{year, month, day}, {hour, min, sec, 0}} = cdr[:start_stamp]
    cdrdate = %Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec, usec: 0}
    legtype = Utils.convertintdefault(cdr[:legtype], 1)
    amd_status = Utils.convertintdefault(cdr[:amd_status], 0)
    nibble_total_billed = Utils.convertfloatdefault(cdr[:nibble_total_billed], 0.0)
    {billed_duration, cdrdate, legtype, amd_status, nibble_total_billed}
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