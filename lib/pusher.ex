defmodule Pusher do
  use GenServer
  require Logger
  alias ExCdrPusher.Repo
  alias ExCdrPusher.CDR

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
    IO.puts "----------------------------------------"
    IO.puts "insert_cdr"

    # TODO: break down into single function (more readable and easy to test)
    {billed_duration, cdrdate, legtype, amd_status, nibble_total_billed} = sanitize_cdr_data(cdr)
    disposition = get_disposition(cdr[:hangup_cause])

    newcdr = %CDR{callid: cdr[:uuid], callerid: cdr[:caller_id_number], phone_number: cdr[:destination_number], starting_date: cdrdate, duration: cdr[:duration], billsec: cdr[:billsec], disposition: disposition, hangup_cause: cdr[:hangup_cause], hangup_cause_q850: Integer.to_string(cdr[:hangup_cause_q850]), leg_type: legtype, amd_status: amd_status, callrequest: cdr[:callrequest_id], used_gateway_id: cdr[:used_gateway_id], user_id: cdr[:user_id], billed_duration: billed_duration, call_cost: nibble_total_billed}
    resinsert = Repo.insert!(newcdr)

    IO.inspect resinsert
    case resinsert do
      %CDR{id: pg_cdr_id} ->
        IO.puts "CDR ID!"
        IO.puts pg_cdr_id
        Collector.mark_cdr_imported(cdr[:rowid], pg_cdr_id)
      {:error, err} ->
        IO.inspect err
      _ ->
        IO.puts "Something unexpected!"
    end

  end

  # calculate billed_duration using billsec & billing increment
  defp calculate_billdur(billsec, increment) do
    if increment > 0 and billsec > 0 do
      if billsec < increment do
        increment
      else
        round(Float.ceil(billsec / increment) * increment)
      end
    else
      if billsec > 0 do
        billsec
      else
        0
      end
    end
  end

  # transform disposition
  defp get_disposition(hangup_cause) do
    case hangup_cause do
      "NORMAL_CLEARING" ->
        "ANSWER"
      "ALLOTTED_TIMEOUT" ->
        "ANSWER"
      "USER_BUSY" ->
        "BUSY"
      "NO_ANSWER" ->
        "NOANSWER"
      "ORIGINATOR_CANCEL" ->
        "CANCEL"
      "NORMAL_CIRCUIT_CONGESTION" ->
        "CONGESTION"
      _ ->
        "FAILED"
    end
  end

  # prepare & sanitize CDR data
  defp sanitize_cdr_data(cdr) do
    IO.inspect cdr
    # We will clean and sanitize some field coming from Sqlite and prepare them PostgreSQL
    billed_duration = calculate_billdur(cdr[:billsec], cdr[:nibble_increment])
    {{year, month, day}, {hour, min, sec, 0}} = cdr[:start_stamp]
    cdrdate = %Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec, usec: 0}
    legtype = case Integer.parse(cdr[:legtype]) do
      :error -> 1
      {intparse, _} -> intparse
    end
    # convert amd_status to integer
    amd_status = case Integer.parse(cdr[:amd_status]) do
      :error -> 0
      {intparse, _} -> intparse
    end
    # convert nibble_total_billed to Floats
    nibble_total_billed = case Float.parse(cdr[:nibble_total_billed]) do
      :error -> 0.0
      {floatparse, _} -> floatparse
    end
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