# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :error_log},
             {LoggerFileBackend, :debug_log}]

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "/var/log/excdr_pusher/elixir-error.log",
  level: :error,
  format: "$time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]

# configuration for the {LoggerFileBackend, :debug_log} backend
config :logger, :debug_log,
  path: "/var/log/excdr_pusher/elixir-debug.log",
  level: :info,
  format: "$time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]

config :excdr_pusher,
  # Collect from
  sqlite_db: "/var/lib/freeswitch/db/freeswitchcdr.db",
  influxdatabase:  "newfiesdialer",
  # ms Time between fetchs (in millisecond)
  tick_frequency: 50,
  # Amount of CDRs to fetch every tick_frequency
  amount_cdr_fetch: 25
  # 500 CDRs per second -> 30.000 per minute
  # 400 CDRs per second -> 24.000 per minute

# Push to
config :excdr_pusher, ExCdrPusher.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://DBUSERNAME:DBPASSWORD@DBHOST/DBNAME"

# InfluxDB configuration
config :excdr_pusher, ExCdrPusher.InConnection,
  host:      "influxdb_host",
  # http_opts: [ insecure: true, proxy: "http://company.proxy" ],
  pool:      [ max_overflow: 0, size: 1 ],
  port:      8086,
  scheme:    "http",
  writer:    Instream.Writer.Line