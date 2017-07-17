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
  path: "/var/log/excdr_pusher/error.log",
  level: :warn,
  format: "$date $time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]

# configuration for the {LoggerFileBackend, :debug_log} backend
config :logger, :debug_log,
  path: "/var/log/excdr_pusher/debug.log",
  level: :info,
  format: "$date $time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]

config :excdr_pusher,
  # Collect from
  sqlite_db: "./private/freeswitchcdr.db",
  influxdatabase:  "newfiesdialer",
  # ms Time between fetchs (in millisecond)
  tick_frequency: 50,
  # Amount of CDRs to fetch every tick_frequency
  amount_cdr_fetch: 1
  # 500 CDRs per second -> 30.000 per minute

# Push to
config :excdr_pusher, ExCdrPusher.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: "postgres://postgres:password@localhost/newfiesdb"

# InfluxDB configuration
config :excdr_pusher, ExCdrPusher.InConnection,
  host:      "influxdb_host",
  # http_opts: [ insecure: true, proxy: "http://company.proxy" ],
  pool:      [ max_overflow: 0, size: 1 ],
  port:      8086,
  scheme:    "http",
  writer:    Instream.Writer.Line

if Mix.env == :dev do
  config :mix_test_watch,
    tasks: [
      "test",
      "credo -a --strict",
      "dialyzer",
    ]
end

# If you need to load configuration from the environment at runtime, you will
# need to do something like the following:
# my_setting = Application.get_env(:myapp, :setting) ||
#     System.get_env("MY_SETTING") || default_val
