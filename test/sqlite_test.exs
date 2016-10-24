defmodule PusherTest do
  use ExUnit.Case, async: true

  # setup do
  #   {:ok, genserver} = PusherPG.start_link([])
  #   {:ok, genserver: genserver}
  # end

  # test "spawns buckets", %{genserver: genserver} do
  test "already start genserver" do
    assert PusherPG.lookup("shopping") == :error

    assert PusherPG.push("hello") == :ok

    assert PusherPG.pop() == "hello"


    # PusherPG.create(genserver, "shopping")
    # assert {:ok, bucket} = Pusher.lookup(genserver, "shopping")

    # KV.Bucket.put(bucket, "milk", 1)
    # assert KV.Bucket.get(bucket, "milk") == 1
  end
end