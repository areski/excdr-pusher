defmodule BillingTest do
  use ExUnit.Case, async: true
  doctest ExCdrPusher.Billing

  alias Ecto.Adapters.SQL.Sandbox
  alias ExCdrPusher.Billing
  alias ExCdrPusher.DataUser

  @user_id 1

  setup do
    # Explicitly get a connection before each test
    :ok = Sandbox.checkout(ExCdrPusher.Repo)
  end

  test "test get_billing_info_per_leg" do
    u = DataUser.get_userprofile(@user_id)
    leg_type = 1
    billing_info = Billing.get_billing_info_per_leg(u, leg_type)
    assert billing_info == %{
      "increment" => 6,
      "min_charge" => Decimal.new("0.12399"),
      "rate" => Decimal.new("0.10000")
    }
  end

  # test "test "

end
