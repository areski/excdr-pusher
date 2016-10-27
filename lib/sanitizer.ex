defmodule ExCdrPusher.Sanitizer do

  alias ExCdrPusher.Utils

  @moduledoc """
  This is the module to sanitize CDRs data
  """

  @doc """
  Prepare and sanitize CDR data.

  We will clean and sanitize data coming from Sqlite and prepare them for PostgreSQL insertion.
  """
  def cdr(cdr) do

    billed_duration = Utils.calculate_billdur(cdr[:billsec], cdr[:nibble_increment])

    {{year, month, day}, {hour, min, sec, 0}} = cdr[:start_stamp]
    cdrdate = %Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec, usec: 0}

    legtype = Utils.convertintdefault(cdr[:legtype], 1)

    amd_status = Utils.convertintdefault(cdr[:amd_status], 0)

    nibble_total_billed = Utils.convertfloatdefault(cdr[:nibble_total_billed], 0.0)

    disposition = Utils.get_disposition(cdr[:hangup_cause])

    hangup_cause_q850 = Utils.convertintdefault(cdr[:hangup_cause_q850], 0)

    user_id = user_id(cdr[:user_id])

    %{
      billed_duration: billed_duration,
      cdrdate: cdrdate,
      legtype: legtype,
      amd_status: amd_status,
      nibble_total_billed: nibble_total_billed,
      disposition: disposition,
      hangup_cause_q850: hangup_cause_q850,
      user_id: user_id,
    }
  end

  @doc """
  Sanitize User ID

  ## Examples

    iex> ExCdrPusher.Sanitizer.user_id("")
    1
    iex> ExCdrPusher.Sanitizer.user_id(1234)
    1234
  """
  def user_id(user_id) do
    if (user_id == ""), do: 1, else: user_id
  end

end