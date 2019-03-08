# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :error_log},
             {LoggerFileBackend, :debug_log}],
  compile_time_purge_level: :info

# configuration for the {LoggerFileBackend, :error_log} backend
config :logger, :error_log,
  path: "/tmp/error.log",
  level: :warn,
  format: "$date $time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]

# configuration for the {LoggerFileBackend, :debug_log} backend
config :logger, :debug_log,
  path: "/tmp/debug.log",
  level: :info,
  format: "$date $time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]

config :excdr_pusher,
  # Collect from
  sqlite_db: "./data/freeswitchcdr-test.db",
  influxdatabase:  "newfiesdialer",
  # ms Time between fetchs (in millisecond)
  tick_frequency: 1000,
  # Amount of CDRs to fetch every 0.1 second
  amount_cdr_fetch: 1,
  enable_billing: true

  # Push to
config :excdr_pusher, ecto_repos: [ExCdrPusher.Repo]

config :excdr_pusher, ExCdrPusher.Repo,
url: "postgres://postgres:password@localhost/newfiesdb",
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox

# InfluxDB configuration
config :excdr_pusher, ExCdrPusher.InConnection,
  host:      "influxdb-host",
  # http_opts: [ insecure: true, proxy: "http://company.proxy" ],
  pool:      [ max_overflow: 0, size: 1 ],
  port:      8086,
  scheme:    "http",
  writer:    Instream.Writer.Line
