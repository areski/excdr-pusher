defmodule CDRDurationSeries do
  use Instream.Series

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_duration"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRBilledDurationSeries do
  use Instream.Series

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_billedduration"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end


defmodule CDRCallCostSeries do
  use Instream.Series

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_callcost"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRHangupCauseSeries do
  use Instream.Series

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_hangup_cause"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRHangupCauseQ850Series do
  use Instream.Series

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_hangup_cause_q850"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end


# field :callid,            :string
# field :callerid,          :string
# field :phone_number,      :string
# field :starting_date,     Ecto.DateTime
# field :duration,          :integer, default: 0
# field :billsec,           :integer, default: 0
# field :disposition,       :string
# field :hangup_cause,      :string
# field :hangup_cause_q850, :integer, default: 0
# field :leg_type,          :integer
# field :amd_status,        :integer
# field :callrequest_id,    :integer
# field :used_gateway_id,   :integer
# field :user_id,           :integer
# field :billed_duration,   :integer
# field :call_cost,         :float, default: 0.0
#