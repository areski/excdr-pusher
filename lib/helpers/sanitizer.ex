defmodule ExCdrPusher.Sanitizer do
  alias ExCdrPusher.Utils
  alias Timex.Timezone, as: Timezone

  @moduledoc """
  This is the module to sanitize CDRs data
  """

  @doc """
  Prepare and sanitize CDR data.

  We will clean and sanitize data coming from Sqlite and prepare them for
  PostgreSQL insertion.
  """
  def cdr(cdr) do
    # get billed_duration
    billed_duration = Utils.calculate_billdur(cdr[:billsec], cdr[:nibble_increment])

    # get cdr date
    # IO.inspect cdr[:start_stamp]
    {{year, month, day}, {hour, min, sec, 0}} = cdr[:start_stamp]
    # cdrdate = %Ecto.DateTime{year: year, month: month, day: day, hour: hour,
    # min: min, sec: sec, usec: 0}
    # Work with naiveDatetime...
    # {:ok, ndt} = NaiveDateTime.from_iso8601("2015-01-23 23:50:07")
    # {:ok, cdrdate} = NaiveDateTime.from_erl({{year, month, day},
    # {hour, min, sec}})
    # dt = %DateTime{year: 2000, month: 2, day: 29, zone_abbr: "CET",
    #             hour: 23, minute: 0, second: 7, microsecond: {0, 0},
    #             utc_offset: 3600, std_offset: 0, time_zone: "Europe/Warsaw"}

    # Using Timex and convert from local timezone to UTC
    dt = Timex.to_datetime({{year, month, day}, {hour, min, sec}}, :local)
    cdrdate = Timezone.convert(dt, "UTC")

    # get legtype
    legtype = Utils.convert_int(cdr[:legtype], 1)

    # get amd_status
    amd_status = Utils.get_amd_status(cdr[:amd_result])

    # get nibble_total_billed
    nibble_total_billed = Utils.convert_float(cdr[:nibble_total_billed], 0.0)

    # Get hangup_cause_q850, on transfer hc_q850 needs to be corrected, Fix for callcenter
    hc_q850 =
      Utils.sanitize_hangup_cause(cdr[:hangup_cause_q850], cdr[:billsec], cdr[:hangup_cause])

    # get user_id
    user_id = clean_id(cdr[:user_id])

    # get campaign_id
    campaign_id = clean_id(cdr[:campaign_id])

    %{
      billed_duration: billed_duration,
      billsec: cdr[:billsec],
      user_id: user_id,
      cdrdate: cdrdate,
      legtype: legtype,
      amd_status: amd_status,
      nibble_total_billed: nibble_total_billed,
      hangup_cause_q850: hc_q850,
      campaign_id: campaign_id,
      sip_to_host: cdr[:sip_to_host]
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
  def clean_id(""), do: 0
  def clean_id(value), do: value
end
