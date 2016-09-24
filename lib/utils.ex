defmodule ExCdrPusher.Utils do

  @doc """
  Convert to int and default to 0
  """
  def convertintdefault(val, defvalue) do
    cond do
      val == nil ->
        defvalue
      val == "" ->
        defvalue
      is_integer(val) ->
        val
      true ->
        case Integer.parse(val) do
          :error -> defvalue
          {intparse, _} -> intparse
        end
    end
  end

  @doc """
  Convert to Float and default to 0.0
  """
  def convertfloatdefault(val, defvalue) do
    cond do
      val == nil ->
        defvalue
      val == "" ->
        defvalue
      is_integer(val) ->
        val
      true ->
        case Float.parse(val) do
          :error -> defvalue
          {floatparse, _} -> floatparse
        end
    end
  end

  @doc """
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
    billsec = convertintdefault(billsec, 0)
    increment = convertintdefault(increment, 0)
    cond do
      increment <= 0 or billsec <= 0 ->
        billsec
      billsec < increment ->
        increment
      true ->
        round(Float.ceil(billsec / increment) * increment)
    end
  end

  @doc """
  Transform disposition
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

end