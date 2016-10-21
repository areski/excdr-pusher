defmodule Pusher do
  use GenServer
  require Logger

  alias ExCdrPusher.Repo
  alias ExCdrPusher.CDR
  alias ExCdrPusher.Sanitizer

  # Todo: Build buffer to store locally the CDR and insert them in batch
  # Batch insert doesnt seem to work with Ecto ?!

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # def init(state) do
  #   {:ok, %{count: 0}}
  # end

  # Insert single CDR
  def insert_cdr(cdr) do
    clean_cdr = Sanitizer.cdr(cdr)
    # maybe we could move construction of %CDR to Sanitizer.cdr and kind of sanitize all the fields

    newcdr = %CDR{
      callid: cdr[:uuid],
      callerid: cdr[:caller_id_number],
      phone_number: cdr[:destination_number],
      starting_date: clean_cdr[:cdrdate],
      duration: cdr[:duration],
      billsec: cdr[:billsec],
      disposition: clean_cdr[:disposition],
      hangup_cause: cdr[:hangup_cause],
      hangup_cause_q850: clean_cdr[:hangup_cause_q850],
      leg_type: clean_cdr[:legtype],
      amd_status: clean_cdr[:amd_status],
      callrequest: cdr[:callrequest_id],
      used_gateway_id: cdr[:used_gateway_id],
      user_id: clean_cdr[:user_id],
      billed_duration: clean_cdr[:billed_duration],
      call_cost: clean_cdr[:nibble_total_billed]
    }
    result = Repo.insert!(newcdr)
    Logger.info "PG CDR inserted..."
    #
    case result do
      %CDR{id: pg_cdr_id} ->
        Logger.info "PG_CDR_ID -> #{pg_cdr_id}"
        Collector.mark_cdr_pg_cdr_id(cdr[:rowid], pg_cdr_id)
      {:error, err} ->
        Collector.mark_cdr_error(cdr[:rowid])
        Logger.error err
    end
    {:ok, 1}
  end

  # Async push CDRs
  def push(cdr) do
    GenServer.cast(__MODULE__, {:push_cdr, cdr})
  end

  def handle_cast({:push_cdr, cdr}, state) do
    # Insert the CDR
    {:ok, nbimport} = insert_cdr(cdr)
    {:noreply, state}
  end

end