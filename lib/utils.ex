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
  Fix callstatus for aleg transfered calls as the call_status is
  propagated from bleg to aleg...

  ## Example
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 10, 'NORMAL_CLEARING')
    16
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(17, 18, 'NORMAL_CLEARING')
    16
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(17, 0, 'BUSY')
    17
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 0, 'LOSE_RACE')
    502
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 0, 'ORIGINATOR_CANCEL')
    487
    iex> ExCdrPusher.Utils.sanitize_hangup_cause(16, 0, 'NORMAL_CLEARING')
    21
  """
  def sanitize_hangup_cause(hangup_cause_q850, billsec, hangup_cause) do
    # If billsec is position then we should have a normal call -> 16
    hangup_cause_q850 =
      cond do
        billsec > 0 ->
          16

        billsec == 0 and hangup_cause == 'NORMAL_CLEARING' ->
          # We will mark those calls as rejected
          21

        true ->
          convert_int(hangup_cause_q850, 0)

      end

    # Fix Callcenter
    case hangup_cause do
      'LOSE_RACE' ->
        502

      'ORIGINATOR_CANCEL' ->
        487

      _ ->
        hangup_cause_q850
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

      _ ->
        0
    end
  end
end
