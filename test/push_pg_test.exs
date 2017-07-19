defmodule PusherPGTest do
  use ExUnit.Case, async: true

  # setup do
  #   {:ok, genserver} = PusherPG.start_link([])
  #   {:ok, genserver: genserver}
  # end

  setup do
    # Explicitly get a connection before each test
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExCdrPusher.Repo)
  end

  test "the truth" do
    assert 1 + 1 == 2
  end

  # test "spawns buckets", %{genserver: genserver} do
  test "test build_cdr_map" do
    cdr = [
      rowid: 29, caller_id_name: "Outbound Call",
      caller_id_number: "0034650780000",
      destination_number: "0034650780000", context: "default",
      start_stamp: {{2016, 9, 20}, {10, 14, 37, 0}},
      answer_stamp: {{2016, 9, 20}, {10, 14, 48, 0}},
      end_stamp: {{2016, 9, 20}, {10, 15, 0, 0}}, duration: 23,
      billsec: 12, hangup_cause: "NORMAL_CLEARING",
      uuid: "eb43ce0a-bd20-46aa-ba14-9a22d6d0193c", bleg_uuid: "",
      account_code: "", used_gateway_id: 1, callrequest_id: 1681,
      nibble_total_billed: "0.020000", nibble_increment: 6,
      dialout_phone_number: "0034650780000", amd_result: "MACHINE",
      legtype: "1", hangup_cause_q850: 16, campaign_id: 1, job_uuid: "",
      imported: 0, pg_cdr_id: 0
    ]

    dt = Timex.to_datetime({{2016, 9, 20}, {10, 14, 37, 0}}, :local)
    starting_date = Timex.Timezone.convert(dt, "UTC")

    assert PusherPG.build_cdr_map(cdr) == %{
      amd_status: 2, billed_duration: 12, billsec: 12, call_cost: 0.02,
      callerid: "0034650780000",
      callid: "eb43ce0a-bd20-46aa-ba14-9a22d6d0193c",
      callrequest_id: 1681, campaign_id: 1,
      duration: 23, hangup_cause: "NORMAL_CLEARING",
      hangup_cause_q850: 16, leg_type: 1, phone_number: "0034650780000",
      starting_date: starting_date,
      used_gateway_id: 1
    }

    # assert PusherPG.push("hello") == :ok

    # assert PusherPG.pop() == "hello"


    # PusherPG.create(genserver, "shopping")
    # assert {:ok, bucket} = Pusher.lookup(genserver, "shopping")

    # KV.Bucket.put(bucket, "milk", 1)
    # assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "test push_cdr insert" do
    assert 1 == 1
    cdr_list = [[rowid: 653039, caller_id_name: "Outbound Call", caller_id_number: "17143604044", destination_number: "17143604044", context: "default", start_stamp: {{2016, 9, 27}, {17, 39, 35, 0}}, answer_stamp: {{2016, 9, 27}, {17, 39, 50, 0}}, end_stamp: {{2016, 9, 27}, {17, 39, 55, 0}}, duration: 20, billsec: 5, hangup_cause: "NORMAL_CLEARING", uuid: "0ad67b59-56d4-4df4-b491-cd30e836838e", bleg_uuid: "", account_code: "", user_id: "", used_gateway_id: 5, callrequest_id: 119102339, nibble_total_billed: "0.001000", nibble_increment: 6, dialout_phone_number: "17143604044", amd_status: "machine", legtype: "1", hangup_cause_q850: 16, imported: 0, pg_cdr_id: 0, campaign_id: 139, start_uepoch: 1474997975000000, answer_uepoch: nil, amd_result: "PERSON"]]

    {:ok, nb_inserted} = PusherPG.insert_cdr(cdr_list)
    assert nb_inserted == 1
  end

  test "test insert many with error" do
    assert 1 == 1
    cdr_list = [[rowid: 653039, caller_id_name: "Outbound Call", caller_id_number: "17143604044", destination_number: "17143604044", context: "default", start_stamp: {{2016, 9, 27}, {17, 39, 35, 0}}, answer_stamp: {{2016, 9, 27}, {17, 39, 50, 0}}, end_stamp: {{2016, 9, 27}, {17, 39, 55, 0}}, duration: 20, billsec: 5, hangup_cause: "NORMAL_CLEARING", uuid: "0ad67b59-56d4-4df4-b491-cd30e836838e", bleg_uuid: "", account_code: "", user_id: "", used_gateway_id: 5, callrequest_id: 119102339, nibble_total_billed: "0.001000", nibble_increment: 6, dialout_phone_number: "17143604044", amd_status: "machine", legtype: "1", hangup_cause_q850: 16, imported: 0, pg_cdr_id: 0, campaign_id: 139, start_uepoch: 1474997975000000, answer_uepoch: nil, amd_result: "PERSON"]]

    {:ok, nb_inserted} = PusherPG.insert_cdr(cdr_list)
    assert nb_inserted == 1
  end

end
