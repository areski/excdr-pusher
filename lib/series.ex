defmodule CDRDurationSeries do
  use Instream.Series

  @moduledoc """
  InfluxDB series definition
  """

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_duration"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRBilledDurationSeries do
  use Instream.Series

  @moduledoc """
  InfluxDB series definition
  """

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_billedduration"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRCallCostSeries do
  use Instream.Series

  @moduledoc """
  InfluxDB series definition
  """

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_callcost"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRHangupCauseSeries do
  use Instream.Series

  @moduledoc """
  InfluxDB series definition
  """

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_hangup_cause"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end

defmodule CDRHangupCauseQ850Series do
  use Instream.Series

  @moduledoc """
  InfluxDB series definition
  """

  series do
    database    Application.fetch_env!(:excdr_pusher, :influxdatabase)
    measurement "cdr_hangup_cause_q850"

    tag :campaign_id, default: 0

    field :value, default: 0
  end
end
