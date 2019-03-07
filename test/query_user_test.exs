defmodule DataQueryUserTest do
  use ExUnit.Case, async: true
  alias Ecto.Adapters.SQL.Sandbox
  alias ExCdrPusher.DataUser

  @user_id 1

  setup do
    # Explicitly get a connection before each test
    :ok = Sandbox.checkout(ExCdrPusher.Repo)
  end

  test "test get_userprofile" do
    u = DataUser.get_userprofile(@user_id)
    assert u.id == 1
  end

  test "test get_userprofile cached" do
    u = DataUser.c__get_userprofile(@user_id)
    assert u.id == 1
    assert u.max_cc >= 0
    assert u.max_cc >= 0
    assert u.call_rate >= 0
    assert u.billing_increment >= 0
    assert u.billing_min_charge >= 0
  end

end
