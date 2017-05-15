# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :excdr_pusher, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:excdr_pusher, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

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
  # Amount of CDRs to fetch every 0.1 second
  amount_cdr_fetch: 50
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