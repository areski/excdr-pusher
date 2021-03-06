defmodule ExCdrPusher.CallCost do
  alias Decimal, as: D
  alias ExCdrPusher.DataUser
  alias ExCdrPusher.Utils
  require Logger

  @moduledoc """
  Module for billing
  """

  @doc """
  Get the billing info for a specific leg
  """
  def get_billing_info_per_leg(user, leg_type) do
    if leg_type == 1 do
      %{
        "rate" => user.call_rate,
        "increment" => user.billing_increment,
        "min_charge" => user.billing_min_charge
      }
    else
      %{
        "rate" => user.bleg_call_rate,
        "increment" => user.bleg_billing_increment,
        "min_charge" => user.bleg_billing_min_charge
      }
    end
  rescue
    x ->
      Logger.error("-> get_billing_info_per_leg user:#{inspect(user)} - #{inspect(x)}")

      %{
        "rate" => 0,
        "increment" => 1,
        "min_charge" => 0
      }
  end

  @doc ~S"""
  Calculate call cost using billsec & billing info

  # Example of billing
  # formula for to avoid rounding ==> (billed_duration / 60) * rate_per_minute
  # 10 secs = 0.1 cents per minute ==> (10sec / 60) * 0.1 = 0,01667$
  # 25 secs = 0.2 cents per minute ==> (25sec / 60) * 0.2 = 0.083$

  ## Example
    iex> ExCdrPusher.CallCost.calculate_call_cost(1, 1, 12)
    0.12399
    iex> ExCdrPusher.CallCost.calculate_call_cost(1, 1, 120)
    0.2
  """
  def calculate_call_cost(user_id, leg_type, billsec) do
    # Configure a precision
    D.set_context(%D.Context{D.get_context() | precision: 15})

    user = DataUser.c__get_userprofile(user_id)
    billing_info = get_billing_info_per_leg(user, leg_type)
    billed_duration = Utils.calculate_billdur(billsec, billing_info["increment"])

    cost = D.mult(D.div(billed_duration, D.from_float(60.0)), D.new(billing_info["rate"]))

    call_cost =
      cond do
        Decimal.cmp(cost, D.from_float(0.0)) == :eq ->
          0.0

        Decimal.cmp(cost, D.new(billing_info["min_charge"])) == :lt ->
          billing_info["min_charge"] |> D.new() |> D.to_float()

        true ->
          cost |> D.to_float()
      end

    # Logger.debug("-> calculate_call_cost - user_id:#{user_id} - call_cost:#{call_cost}")
    call_cost
  end
end
