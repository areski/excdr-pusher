defmodule PusherPG do
  use GenServer
  require Logger

  alias ExCdrPusher.Repo
  alias ExCdrPusher.CDR
  alias ExCdrPusher.Sanitizer

  @moduledoc """
  This is the GenServer to push CDRs to PostgreSQL...
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Build CDR Map
  """
  def build_cdr_map(cdr) do
    # Sanitize CDR
    clean_cdr = Sanitizer.cdr(cdr)
    # maybe we could move construction of %CDR to Sanitizer.cdr and kind of sanitize all the fields
    # so we use clean_cdr[:field_name_xy] everywhere
    %{
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
      callrequest_id: cdr[:callrequest_id],
      used_gateway_id: cdr[:used_gateway_id],
      # user_id: clean_cdr[:user_id],
      campaign_id: clean_cdr[:campaign_id],
      billed_duration: clean_cdr[:billed_duration],
      call_cost: clean_cdr[:nibble_total_billed]
    }
  end

  @doc """
  Insert CDR in batch
  """
  def insert_cdr(cdr_list) do
    cdr_map = Enum.map(cdr_list, &build_cdr_map/1)
    {nb_inserted, _} = Repo.insert_all(CDR, cdr_map, returning: false)
    Logger.info "PG CDRs inserted (#{nb_inserted})"

    #
    # update CDR ID disabled / to implement it we need to use returning: true
    # and use the callid to know which Sqlite CDR to update
    #
    # case result do
    #   %CDR{id: pg_cdr_id} ->
    #     Logger.info "PG_CDR_ID -> #{pg_cdr_id}"
    #     Collector.update_cdr_ok(cdr[:rowid], pg_cdr_id)
    #   {:error, err} ->
    #     Collector.update_cdr_error(cdr[:rowid])
    #     Logger.error err
    # end
    {:ok, nb_inserted}
  end

  @doc """
  Async push CDRs
  """
  def push(cdr) do
    GenServer.cast(__MODULE__, {:push_cdr, cdr})
  end

  @doc """
  handle_cast to insert CDRs
  """
  def handle_cast({:push_cdr, cdr}, state) do
    {:ok, _} = insert_cdr(cdr)
    {:noreply, state}
  end

end