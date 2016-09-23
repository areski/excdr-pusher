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
    Collector.rollback_cdr_imported({:ok, cdrs})
    Logger.debug "write_cdrs..."
    # Rollback all CDRs (Not used as we will handle error one by one)
    {:ok, pid} = Postgrex.start_link(hostname: "localhost2", username: "postgres",
                                     password: "password", database: "newfiesdb",
                                     backoff_type: :stop)
    # msg = Postgrex.start_link(hostname: "localhost2", username: "postgres",
    #                                  password: "password", database: "newfiesdb",
    #                                  backoff_type: :stop)

    # IO.inspect msg
    # {:ok, %Postgrex.Result{}} = Postgrex.query(pid, "SELECT 123", [])
    # IO.inspect cdrs
    # Write to PostgreSQL
    # results = Enum.map(cdrs, fn(x) -> insert_cdr(pid, x) end)

  end

  def insert_cdr(pid, cdr) do
    IO.puts "----------------------------------------"
    IO.puts "insert_cdr"

    {billed_duration, cdrdate, legtype, amd_status, nibble_total_billed} = sanitize_cdr_data(cdr)

    res = Postgrex.query!(pid,
      "INSERT INTO dialer_cdr22 (callid, callerid, phone_number, starting_date, duration, billsec, disposition, hangup_cause, hangup_cause_q850, leg_type, amd_status, callrequest, used_gateway_id, user_id, billed_duration, call_cost) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16)",
      [cdr[:uuid], cdr[:caller_id_number], cdr[:destination_number], cdrdate, cdr[:duration], cdr[:billsec], cdr[:hangup_cause], cdr[:hangup_cause], Integer.to_string(cdr[:hangup_cause_q850]), legtype, amd_status, cdr[:callrequest_id], cdr[:used_gateway_id], cdr[:user_id], billed_duration, nibble_total_billed])

    IO.inspect res
    case res do
      %Postgrex.Result{ num_rows: 1} -> IO.puts "ALL GOOD!"
      :error -> IO.puts "AIE AIE!!!"
    end

    # %Postgrex.Result{num_rows: 1}
    # %Postgrex.Result{command: :insert, columns: nil, rows: nil, num_rows: 1}}
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
      billsec
    end
  end

  # prepare & sanitize CDR data
  defp sanitize_cdr_data(cdr) do
    IO.inspect cdr
    # We will clean and sanitize some field coming from Sqlite and prepare them PostgreSQL
    billed_duration = calculate_billdur(cdr[:billsec], cdr[:nibble_increment])
    {{year, month, day}, {hour, min, sec, 0}} = cdr[:start_stamp]
    cdrdate = %Postgrex.Timestamp{year: year, month: month, day: day, hour: hour, min: min, sec: sec, usec: 0}
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