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
      billsec: 12, uuid: "eb43ce0a-bd20-46aa-ba14-9a22d6d0193c", bleg_uuid: "",
      account_code: "", callrequest_id: 1681,
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
      duration: 23, hangup_cause_q850: 16, leg_type: 1,
      phone_number: "0034650780000", starting_date: starting_date
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
    cdr_list = [[rowid: 653039, caller_id_name: "Outbound Call", caller_id_number: "17143604044", destination_number: "17143604044", context: "default", start_stamp: {{2016, 9, 27}, {17, 39, 35, 0}}, answer_stamp: {{2016, 9, 27}, {17, 39, 50, 0}}, end_stamp: {{2016, 9, 27}, {17, 39, 55, 0}}, duration: 20, billsec: 5, uuid: "0ad67b59-56d4-4df4-b491-cd30e836838e", bleg_uuid: "", account_code: "", user_id: "", callrequest_id: 119102339, nibble_total_billed: "0.001000", nibble_increment: 6, dialout_phone_number: "17143604044", amd_status: "machine", legtype: "1", hangup_cause_q850: 16, imported: 0, pg_cdr_id: 0, campaign_id: 139, start_uepoch: 1474997975000000, answer_uepoch: nil, amd_result: "PERSON"]]

    {:ok, nb_inserted} = PusherPG.insert_cdr(cdr_list)
    assert nb_inserted == 1
  end

  test "test insert many with error" do
    assert 1 == 1
    cdr_list = [[rowid: 2210298, caller_id_name: "", caller_id_number: "16502636531", destination_number: "12094282743", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 48, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 8, billsec: 0, uuid: "d68fa513-c087-41c1-b2a0-afed8b62d726", bleg_uuid: "", account_code: "", start_uepoch: 1500483828069576, answer_uepoch: 0, user_id: 4, callrequest_id: 25808191, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+12094282743", amd_result: "", legtype: "1", hangup_cause_q850: 18, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2210297, caller_id_name: "", caller_id_number: "16502636531", destination_number: "16696734333", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 0, billsec: 0, uuid: "f380dc54-1baa-4d5a-b15d-a949da500583", bleg_uuid: "", account_code: "", start_uepoch: 1500483836689568, answer_uepoch: 0, user_id: 4, callrequest_id: 25810137, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+16696734333", amd_result: "", legtype: "1", hangup_cause_q850: 41, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2210296, caller_id_name: "", caller_id_number: "16502636531", destination_number: "19256944139", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 54, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 2, billsec: 0, uuid: "3f626248-509f-4413-b1ce-c202e0a63d50", bleg_uuid: "", account_code: "", start_uepoch: 1500483834209567, answer_uepoch: 0, user_id: 4, callrequest_id: 25808565, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+19256944139", amd_result: "", legtype: "1", hangup_cause_q850: 41, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2210295, caller_id_name: "", caller_id_number: "16502636531", destination_number: "14087228813", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 48, 0}}, answer_stamp: {{2017, 7, 19}, {10, 3, 54, 0}}, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 8, billsec: 2, uuid: "bf9fecc6-ad08-44e9-afbb-72913b8b9dc6", bleg_uuid: "", account_code: "", start_uepoch: 1500483828589565, answer_uepoch: 1500483834889570, user_id: 4, callrequest_id: 25780389, nibble_total_billed: "0.000700", nibble_increment: 6, dialout_phone_number: "+14087228813", amd_result: "MACHINE", legtype: "1", hangup_cause_q850: 16, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2210294, caller_id_name: "", caller_id_number: "16502636531", destination_number: "12094758298", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 51, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 5, billsec: 0, uuid: "1ca0509d-e2e6-401c-9f0f-749dbdf34d56", bleg_uuid: "", account_code: "", start_uepoch: 1500483831749568, answer_uepoch: 0, user_id: 4, callrequest_id: 25808420, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+12094758298", amd_result: "", legtype: "1", hangup_cause_q850: 41, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2210293, caller_id_name: "", caller_id_number: "16502636531", destination_number: "12094804288", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 47, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 9, billsec: 0, uuid: "cfdc912e-a902-4030-9f7b-0c9889bffde0", bleg_uuid: "", account_code: "", start_uepoch: 1500483827549565, answer_uepoch: 0, user_id: 4, callrequest_id: 25808164, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+12094804288", amd_result: "", legtype: "1", hangup_cause_q850: 41, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2210292, caller_id_name: "", caller_id_number: "16502636531", destination_number: "16288627246", context: "default", start_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {10, 3, 56, 0}}, duration: 0, billsec: 0, uuid: "2e752b80-510e-49f8-a5fc-501acdea65ff", bleg_uuid: "", account_code: "", start_uepoch: 1500483836669570, answer_uepoch: 0, user_id: 4, callrequest_id: 25810129, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+16288627246", amd_result: "", legtype: "1", hangup_cause_q850: 41, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2180141, caller_id_name: "", caller_id_number: "16502636531", destination_number: "12094946694", context: "default", start_stamp: {{2017, 7, 19}, {9, 51, 48, 0}}, answer_stamp: nil, end_stamp: {{2017, 7, 19}, {9, 51, 53, 0}}, duration: 5, billsec: 0, uuid: "d25e9928-5d1c-4d34-859f-425d2faea1f0", bleg_uuid: "", account_code: "", start_uepoch: 1500483108669573, answer_uepoch: 0, user_id: 4, callrequest_id: 25720416, nibble_total_billed: "", nibble_increment: 6, dialout_phone_number: "+12094946694", amd_result: "", legtype: "1", hangup_cause_q850: 18, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2180140, caller_id_name: "", caller_id_number: "16502636531", destination_number: "17073260854", context: "default", start_stamp: {{2017, 7, 19}, {9, 51, 41, 0}}, answer_stamp: {{2017, 7, 19}, {9, 51, 50, 0}}, end_stamp: {{2017, 7, 19}, {9, 51, 53, 0}}, duration: 12, billsec: 3, uuid: "3a937d51-8b8a-4c89-ab93-22b3d6a52063", bleg_uuid: "", account_code: "", start_uepoch: 1500483101589575, answer_uepoch: 1500483110609571, user_id: 4, callrequest_id: 25731596, nibble_total_billed: "0.000700", nibble_increment: 6, dialout_phone_number: "+17073260854", amd_result: "MACHINE", legtype: "1", hangup_cause_q850: 16, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2180139, caller_id_name: "", caller_id_number: "16502636531", destination_number: "19254105007", context: "default", start_stamp: {{2017, 7, 19}, {9, 51, 18, 0}}, answer_stamp: {{2017, 7, 19}, {9, 51, 48, 0}}, end_stamp: {{2017, 7, 19}, {9, 51, 53, 0}}, duration: 35, billsec: 5, uuid: "e0d51a2b-870d-448d-9c3a-31fedfc82c64", bleg_uuid: "", account_code: "", start_uepoch: 1500483078609567, answer_uepoch: 1500483108149566, user_id: 4, callrequest_id: 25717830, nibble_total_billed: "0.000700", nibble_increment: 6, dialout_phone_number: "+19254105007", amd_result: "NOTSURE", legtype: "3", hangup_cause_q850: 16, campaign_id: 164, imported: 0, pg_cdr_id: 0], [rowid: 2180138, caller_id_name: "", caller_id_number: "16502636531", destination_number: "15303069023", context: "default", start_stamp: {{2017, 7, 19}, {9, 51, 47, 0}}, answer_stamp: {{2017, 7, 19}, {9, 51, 51, 0}}, end_stamp: {{2017, 7, 19}, {9, 51, 53, 0}}, duration: 6, billsec: 2, uuid: "fff39057-6f48-4cfa-baeb-45a4dfafcfb8", bleg_uuid: "", account_code: "", start_uepoch: 1500483107109570, answer_uepoch: 1500483111069566, user_id: 4, callrequest_id: 25720466, nibble_total_billed: "0.000700", nibble_increment: 6, dialout_phone_number: "+15303069023", amd_result: "MACHINE", legtype: "1", hangup_cause_q850: 16, campaign_id: 164, imported: 0, pg_cdr_id: 0]]

    {:ok, nb_inserted} = PusherPG.insert_cdr(cdr_list)
    assert nb_inserted == 11
  end

end
