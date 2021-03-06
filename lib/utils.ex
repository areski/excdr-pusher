defmodule ExCdrPusher.Utils do
  @moduledoc """
  This module contains a misc of useful functions
  """

  @doc ~S"""
  Convert to int and default to 0

  ## Example
    iex> ExCdrPusher.Utils.convert_int(nil, 6)
    6
    iex> ExCdrPusher.Utils.convert_int("", 6)
    6
    iex> ExCdrPusher.Utils.convert_int(12, 6)
    12
  """
  def convert_int(nil, default), do: default
  def convert_int("", default), do: default
  def convert_int(value, _) when is_integer(value), do: value

  def convert_int(value, default) do
    case Integer.parse(value) do
      :error -> default
      {intparse, _} -> intparse
    end
  end

  @doc ~S"""
  Convert to float and default to 0.0

  ## Example
    iex> ExCdrPusher.Utils.convert_float(nil, 6)
    6
    iex> ExCdrPusher.Utils.convert_float("", 6)
    6
    iex> ExCdrPusher.Utils.convert_float(12, 6)
    12
    iex> ExCdrPusher.Utils.convert_float("20", 6)
    20.0
  """
  def convert_float(nil, default), do: default
  def convert_float("", default), do: default
  def convert_float(value, _) when is_float(value), do: value
  def convert_float(value, _) when is_integer(value), do: value

  def convert_float(value, default) do
    case Float.parse(value) do
      :error -> default
      {floatparse, _} -> floatparse
    end
  end

  @doc ~S"""
  Calculate billed_duration using billsec & billing increment

  ## Example
    iex> ExCdrPusher.Utils.calculate_billdur(12, 6)
    12
    iex> ExCdrPusher.Utils.calculate_billdur(20, 6)
    24
    iex> ExCdrPusher.Utils.calculate_billdur(0, 0)
    0
    iex> ExCdrPusher.Utils.calculate_billdur("", "")
    0
  """
  def calculate_billdur(billsec, increment) do
    billsec = convert_int(billsec, 0)
    increment = convert_int(increment, 0)

    cond do
      increment <= 0 or billsec <= 0 ->
        billsec

      billsec < increment ->
        increment

      true ->
        round(Float.ceil(billsec / increment) * increment)
    end
  end

  @doc ~S"""
  Fix destination when using WebRTC, in order
  to avoid ending up with destination like `bivi5t2k`

  1) If Bleg
  2) If variable_dialed_user is not empty
  3) if variable_dialed_user start with `agent-`


  ## Example
    iex> ExCdrPusher.Utils.fix_destination(1, "", "123456789")
    "123456789"
    iex> ExCdrPusher.Utils.fix_destination(1, nil, "123456789")
    "123456789"
    iex> ExCdrPusher.Utils.fix_destination(2, "", "123456789")
    "123456789"
    iex> ExCdrPusher.Utils.fix_destination(1, "agent-1234", "123456789")
    "123456789"
    iex> ExCdrPusher.Utils.fix_destination(2, "88888", "123456789")
    "123456789"
    iex> ExCdrPusher.Utils.fix_destination(2, "agent-1234", "123456789")
    "agent-1234"
  """
  def fix_destination(_, nil, destination), do: destination
  def fix_destination(_, "", destination), do: destination
  def fix_destination(leg_type, _, destination) when leg_type != 2, do: destination

  def fix_destination(_, dialed_user, destination) do
    if String.starts_with?(dialed_user, "agent-") do
      dialed_user
    else
      destination
    end
  end

  @doc ~S"""
  Fix callstatus for aleg transfered calls as the call_status is
  propagated from bleg to aleg...

  ## Example
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 10, "NORMAL_CLEARING")
    [16, 10]
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(17, 18, "NORMAL_CLEARING")
    [16, 18]
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(17, 0, "BUSY")
    [17, 0]
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 0, "LOSE_RACE")
    [502, 0]
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 0, "ORIGINATOR_CANCEL")
    [487, 0]
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 0, "NORMAL_CLEARING")
    [16, 1]
  """
  def sanitize_hangup_cause(hangup_cause_q850, billsec, hangup_cause) do
    # If billsec is position then we should have a normal call -> 16
    cond do
      hangup_cause == "LOSE_RACE" ->
        [502, billsec]

      hangup_cause == "ORIGINATOR_CANCEL" ->
        [487, billsec]

      hangup_cause_q850 == 16 and billsec == 0 and hangup_cause == "NORMAL_CLEARING" ->
        # Now we will set those call at 1 second as they have been answered
        [16, 1]

      billsec > 0 ->
        [16, billsec]

      billsec == 0 and hangup_cause == "NORMAL_CLEARING" ->
        # We will mark those calls as rejected
        [21, billsec]

      true ->
        [convert_int(hangup_cause_q850, 0), billsec]
    end
  end

  @doc ~S"""
  Transform amd_result

  ## Example
    iex> ExCdrPusher.Utils.get_amd_status("HUMAN")
    1
    iex> ExCdrPusher.Utils.get_amd_status("PERSON")
    1
    iex> ExCdrPusher.Utils.get_amd_status("MACHINE")
    2
    iex> ExCdrPusher.Utils.get_amd_status("UNSURE")
    3
    iex> ExCdrPusher.Utils.get_amd_status("NOTSURE")
    3
    iex> ExCdrPusher.Utils.get_amd_status("")
    0
  """
  def get_amd_status(amd_status) do
    case amd_status do
      "HUMAN" ->
        1

      "PERSON" ->
        1

      "MACHINE" ->
        2

      "UNSURE" ->
        3

      "NOTSURE" ->
        3

      _ ->
        0
    end
  end
end
