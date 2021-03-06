defmodule PusherPG do
  use GenServer
  require Logger

  alias Application, as: App
  alias Ecto.Adapters.SQL
  alias ExCdrPusher.CallCost
  alias ExCdrPusher.CDR
  alias ExCdrPusher.Repo
  alias ExCdrPusher.Sanitizer

  @moduledoc """
  This is the GenServer to push CDRs to PostgreSQL...
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

  @doc """
  bill or not to bill the CDR
  """
  def bill_cdr(sanitized_cdr) do
    if App.fetch_env!(:excdr_pusher, :enable_billing) do
      # Billing enabled
      call_cost =
        CallCost.calculate_call_cost(
          sanitized_cdr[:user_id],
          sanitized_cdr[:legtype],
          sanitized_cdr[:billsec]
        )

      # Add Billing for that user
      Biller.add_userid(sanitized_cdr[:user_id], call_cost)
      call_cost
    else
      0.0
    end
  end

  @doc """
  Build CDR Map
  """
  def build_cdr_map(cdr) do
    sanitized_cdr = Sanitizer.cdr(cdr)
    call_cost = bill_cdr(sanitized_cdr)

    # maybe we could move construction of %CDR to Sanitizer.cdr and
    # kind of sanitize all the fields
    # so we use sanitized_cdr[:field_name_xy] everywhere
    %{
      callid: cdr[:uuid],
      callerid: cdr[:caller_id_number],
      phone_number: sanitized_cdr[:destination_number],
      starting_date: sanitized_cdr[:cdrdate],
      duration: cdr[:duration],
      billsec: sanitized_cdr[:billsec],
      leg_type: sanitized_cdr[:legtype],
      amd_status: sanitized_cdr[:amd_status],
      callrequest_id: cdr[:callrequest_id],
      hangup_cause_q850: sanitized_cdr[:hangup_cause_q850],
      campaign_id: sanitized_cdr[:campaign_id],
      billed_duration: sanitized_cdr[:billed_duration],
      call_cost: call_cost
    }
  end

  @doc ~S"""
  Build Select to process retry

  ## Example
    iex> PusherPG.build_select_retry([rowid: 29, caller_id_name: "Outbound Call", caller_id_number: "0034650780000", destination_number: "0034650780000", start_stamp: {{2016, 9, 20}, {10, 14, 37, 0}}, duration: 23, billsec: 12, uuid: "eb43ce0a-bd20-46aa-ba14-9a22d6d0193c", callrequest_id: 1681, nibble_total_billed: "0.020000", nibble_increment: 6, amd_result: "MACHINE", legtype: "1", hangup_cause_q850: 16, campaign_id: 1, imported: 0])
    "process_cdr_retry(1681, 1, 1, 16, 2)"
  """
  def build_select_retry(cdr) do
    sanitized_cdr = Sanitizer.cdr(cdr)

    if sanitized_cdr[:legtype] == 1 do
      "process_cdr_retry(#{cdr[:callrequest_id]}, #{sanitized_cdr[:campaign_id]}, " <>
        "#{sanitized_cdr[:legtype]}, #{sanitized_cdr[:hangup_cause_q850]}, #{
          sanitized_cdr[:amd_status]
        })"
    end
  end

  @doc """
  Build and run custom SQL
  """
  def build_sql_select_retry(cdrs) do
    sql_retry =
      cdrs
      |> Enum.filter(fn x -> x[:legtype] == "1" end)
      |> Enum.map(&build_select_retry/1)
      |> Enum.join(", ")

    "SELECT " <> sql_retry
  end

  @doc """
  Insert CDR in batch
  """
  def insert_cdr(cdr_list) do
    cdr_map = Enum.map(cdr_list, &build_cdr_map/1)
    # Logger.info("cdr_map: #{inspect(cdr_map)}")
    {nb_inserted, _} = Repo.insert_all(CDR, cdr_map, returning: false)

    if nb_inserted > 0 do
      Logger.info("PG CDRs inserted (#{nb_inserted})")

      sql_retry = build_sql_select_retry(cdr_list)
      result = SQL.query!(Repo, sql_retry)

      Logger.debug(fn ->
        "PG CDRs Retry (#{result.num_rows} - #{inspect(result.rows)})"
      end)
    end

    {:ok, nb_inserted}
  end

  @doc """
  Sync push CDRs
  """
  def sync_push(cdr) do
    GenServer.call(__MODULE__, {:push_cdr, cdr})
  end

  @doc """
  handle_cast to insert CDRs
  """
  def handle_call({:push_cdr, cdr}, _from, state) do
    {res, _} = insert_cdr(cdr)
    {:reply, res, state}
  end

  @doc """
  Async push CDRs
  """
  def async_push(cdr) do
    GenServer.cast(__MODULE__, {:push_cdr, cdr})
  end

  @doc """
  handle_cast to insert CDRs
  """
  def handle_cast({:push_cdr, cdr}, state) do
    {:ok, _} = insert_cdr(cdr)
    {:noreply, state}
  end

  def terminate(_reason, _state) do
    # Do Shutdown Stuff
    Process.sleep(1000)
    :normal
  end
end
