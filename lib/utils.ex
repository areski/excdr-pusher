defmodule ExCdrPusher.Utils do

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
    iex> ExCdrPusher.Utils.fix_hangup_cause_aleg("ANSWER", 16, 10)
    {"ANSWER", 16}
    iex> ExCdrPusher.Utils.fix_hangup_cause_aleg("BUSY", 17, 18)
    {"ANSWER", 16}
    iex> ExCdrPusher.Utils.fix_hangup_cause_aleg("BUSY", 17, 0)
    {"BUSY", 17}
  """
  def fix_hangup_cause_aleg(disposition, hangup_cause_q850, billsec) do
    cond do
      billsec > 0 ->
        {"ANSWER", 16}
      true ->
        {disposition, hangup_cause_q850}
    end
  end


  @doc ~S"""
  Transform disposition

  ## Example
    iex> ExCdrPusher.Utils.get_disposition("NORMAL_CLEARING")
    "ANSWER"
    iex> ExCdrPusher.Utils.get_disposition("USER_BUSY")
    "BUSY"
  """
  def get_disposition(hangup_cause) do
    case hangup_cause do
      "NORMAL_CLEARING" ->
        "ANSWER"
      "ALLOTTED_TIMEOUT" ->
        "ANSWER"
      "USER_BUSY" ->
        "BUSY"
      "NO_ANSWER" ->
        "NOANSWER"
      "ORIGINATOR_CANCEL" ->
        "CANCEL"
      "NORMAL_CIRCUIT_CONGESTION" ->
        "CONGESTION"
      _ ->
        "FAILED"
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
  def get_amd_status(hangup_cause) do
    case hangup_cause do
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