defmodule PusherPGTest do
  use ExUnit.Case, async: true
  alias Ecto.Adapters.SQL
  alias Ecto.Adapters.SQL.Sandbox
  alias Timex.Timezone
  doctest PusherPG

  # setup do
  #   {:ok, genserver} = PusherPG.start_link([])
  #   {:ok, genserver: genserver}
  # end

  setup do
    # Explicitly get a connection before each test
    :ok = Sandbox.checkout(ExCdrPusher.Repo)
  end

  # test "spawns buckets", %{genserver: genserver} do
  test "test build_cdr_map" do
    cdr = [
      rowid: 29,
      caller_id_name: "Outbound Call",
      caller_id_number: "0034650780000",
      destination_number: "0034650780000",
      start_stamp: {{2016, 9, 20}, {10, 14, 37, 0}},
      duration: 23,
      billsec: 12,
      uuid: "eb43ce0a-bd20-46aa-ba14-9a22d6d0193c",
      # user_id: "",
      callrequest_id: 1681,
      nibble_total_billed: "0.020000",
      nibble_increment: 6,
      amd_result: "MACHINE",
      legtype: "1",
      hangup_cause_q850: 16,
      campaign_id: 1,
      imported: 0
    ]

    dt = Timex.to_datetime({{2016, 9, 20}, {10, 14, 37, 0}}, :local)
    starting_date = Timezone.convert(dt, "UTC")

    assert PusherPG.build_cdr_map(cdr) == %{
             amd_status: 2,
             billed_duration: 12,
             billsec: 12,
             call_cost: 0.0,
             callerid: "0034650780000",
             callid: "eb43ce0a-bd20-46aa-ba14-9a22d6d0193c",
             callrequest_id: 1681,
             campaign_id: 1,
             duration: 23,
             hangup_cause_q850: 16,
             leg_type: 1,
             phone_number: "0034650780000",
             starting_date: starting_date
           }

    # assert PusherPG.push("hello") == :ok
    # assert PusherPG.pop() == "hello"

    # PusherPG.create(genserver, "shopping")
    # assert {:ok, bucket} = Pusher.lookup(genserver, "shopping")

    # KV.Bucket.put(bucket, "milk", 1)
    # assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "test push_cdr insert" do
    cdr_list = [
      [
        rowid: 653_039,
        caller_id_name: "Outbound Call",
        caller_id_number: "17143604044",
        destination_number: "17143604044",
        start_stamp: {{2016, 9, 27}, {17, 39, 35, 0}},
        duration: 20,
        billsec: 5,
        uuid: "0ad67b59-56d4-4df4-b491-cd30e836838e",
        user_id: "",
        callrequest_id: 119_102_339,
        nibble_total_billed: "0.001000",
        nibble_increment: 6,
        amd_status: "machine",
        legtype: "1",
        hangup_cause_q850: 16,
        imported: 0,
        campaign_id: 139,
        amd_result: "PERSON"
      ]
    ]

    {:ok, nb_inserted} = PusherPG.insert_cdr(cdr_list)
    assert nb_inserted == 1
  end

  test "test insert many with error" do
    cdr_list = [
      [
        rowid: 2_180_140,
        caller_id_name: "",
        caller_id_number: "16502636531",
        destination_number: "17073260854",
        start_stamp: {{2017, 7, 19}, {9, 51, 41, 0}},
        duration: 12,
        billsec: 3,
        uuid: "3a937d51-8b8a-4c89-ab93-22b3d6a52063",
        user_id: 4,
        callrequest_id: 25_731_596,
        nibble_total_billed: "0.000700",
        nibble_increment: 6,
        amd_result: "MACHINE",
        legtype: "1",
        hangup_cause_q850: 16,
        campaign_id: 164,
        imported: 0
      ],
      [
        rowid: 2_180_139,
        caller_id_name: "",
        caller_id_number: "16502636531",
        destination_number: "19254105007",
        start_stamp: {{2017, 7, 19}, {9, 51, 18, 0}},
        duration: 35,
        billsec: 5,
        uuid: "e0d51a2b-870d-448d-9c3a-31fedfc82c64",
        user_id: 4,
        callrequest_id: 25_717_830,
        nibble_total_billed: "0.000700",
        nibble_increment: 6,
        amd_result: "NOTSURE",
        legtype: "3",
        hangup_cause_q850: 16,
        campaign_id: 164,
        imported: 0
      ],
      [
        rowid: 2_180_138,
        caller_id_name: "",
        caller_id_number: "16502636531",
        destination_number: "15303069023",
        start_stamp: {{2017, 7, 19}, {9, 51, 47, 0}},
        duration: 6,
        billsec: 2,
        uuid: "fff39057-6f48-4cfa-baeb-45a4dfafcfb8",
        user_id: 4,
        callrequest_id: 25_720_466,
        nibble_total_billed: "0.000700",
        nibble_increment: 6,
        amd_result: "MACHINE",
        legtype: "1",
        hangup_cause_q850: 16,
        campaign_id: 164,
        imported: 0
      ]
    ]

    {:ok, nb_inserted} = PusherPG.insert_cdr(cdr_list)
    assert nb_inserted == 3
  end

  test "test build_select_retry" do
    cdr_list = [
      rowid: 2_210_298,
      caller_id_name: "",
      caller_id_number: "16502636531",
      destination_number: "12094282743",
      start_stamp: {{2017, 7, 19}, {10, 3, 48, 0}},
      duration: 8,
      billsec: 0,
      uuid: "d68fa513-c087-41c1-b2a0-afed8b62d726",
      user_id: 4,
      callrequest_id: 25_808_191,
      nibble_total_billed: "",
      nibble_increment: 6,
      amd_result: "",
      legtype: "1",
      hangup_cause_q850: 18,
      campaign_id: 164,
      imported: 0
    ]

    sql_retry = PusherPG.build_select_retry(cdr_list)
    assert sql_retry == "process_cdr_retry(25808191, 164, 1, 18, 0)"
  end

  test "test build_select_retry with array" do
    cdr_list = [
      [
        rowid: 2_210_298,
        caller_id_name: "",
        caller_id_number: "16502636531",
        destination_number: "12094282743",
        start_stamp: {{2017, 7, 19}, {10, 3, 48, 0}},
        duration: 8,
        billsec: 0,
        uuid: "d68fa513-c087-41c1-b2a0-afed8b62d726",
        user_id: 4,
        callrequest_id: 25_808_191,
        nibble_total_billed: "",
        nibble_increment: 6,
        amd_result: "",
        legtype: "1",
        hangup_cause_q850: 18,
        campaign_id: 164,
        imported: 0
      ],
      [
        rowid: 2_210_298,
        caller_id_name: "",
        caller_id_number: "16502636531",
        destination_number: "12094282743",
        start_stamp: {{2017, 7, 19}, {10, 3, 48, 0}},
        duration: 8,
        billsec: 0,
        uuid: "d68fa513-c087-41c1-b2a0-afed8b62d726",
        user_id: 4,
        callrequest_id: 25_808_191,
        nibble_total_billed: "",
        nibble_increment: 6,
        amd_result: "",
        legtype: "1",
        hangup_cause_q850: 18,
        campaign_id: 164,
        imported: 0
      ]
    ]

    assert PusherPG.build_sql_select_retry(cdr_list) ==
             "SELECT process_cdr_retry(25808191, 164, 1, 18, 0), process_cdr_retry(25808191, 164, 1, 18, 0)"
  end

  test "raw query" do
    result = SQL.query!(ExCdrPusher.Repo, "SELECT NOW()")
    assert result.num_rows == 1
  end
end
