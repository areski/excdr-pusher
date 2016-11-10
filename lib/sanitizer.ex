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
    # get billed_duration
    billed_duration = Utils.calculate_billdur(cdr[:billsec], cdr[:nibble_increment])

    # get cdr date
    {{year, month, day}, {hour, min, sec, 0}} = cdr[:start_stamp]
    cdrdate = %Ecto.DateTime{year: year, month: month, day: day, hour: hour, min: min, sec: sec, usec: 0}

    # get legtype
    legtype = Utils.convert_int(cdr[:legtype], 1)

    # get amd_status
    amd_status = Utils.get_amd_status(cdr[:amd_result])

    # get nibble_total_billed
    nibble_total_billed = Utils.convert_float(cdr[:nibble_total_billed], 0.0)

    # get disposition
    disposition = Utils.get_disposition(cdr[:hangup_cause])

    # get hangup_cause_q850
    hangup_cause_q850 = Utils.convert_int(cdr[:hangup_cause_q850], 0)

    # on transfer the disposition & hangup_cause_q850 needs to be manually corrected
    {disposition, hangup_cause_q850} = Utils.fix_hangup_cause_aleg(disposition, hangup_cause_q850, cdr[:billsec])

    # get user_id
    user_id = clean_id(cdr[:user_id])

    # get campaign_id
    campaign_id = clean_id(cdr[:campaign_id])

    %{
      billed_duration: billed_duration,
      cdrdate: cdrdate,
      legtype: legtype,
      amd_status: amd_status,
      nibble_total_billed: nibble_total_billed,
      disposition: disposition,
      hangup_cause_q850: hangup_cause_q850,
      user_id: user_id,
      campaign_id: campaign_id,
    }
  end

  @doc """
  Sanitize User ID, Campaign ID

  ## Examples

    iex> ExCdrPusher.Sanitizer.clean_id("")
    1
    iex> ExCdrPusher.Sanitizer.clean_id(1234)
    1234
  """
  def clean_id(""), do: 1
  def clean_id(value), do: value

end