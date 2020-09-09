# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# tell logger to load a LoggerFileBackend processes
config :logger,
  backends: [{LoggerFileBackend, :error_log}, {LoggerFileBackend, :debug_log}],
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

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
  sqlite_db: "/var/lib/freeswitch/db/freeswitchcdr.db",
  # heartbeat in ms
  tick_frequency: 20,
  # Amount of CDRs to fetch
  amount_cdr_fetch: 10,
  enable_billing: true

# Push to
config :excdr_pusher, ecto_repos: [ExCdrPusher.Repo]

config :excdr_pusher, ExCdrPusher.Repo,
  url: "postgres://DBUSERNAME:DBPASSWORD@DBHOST/DBNAME",
  pool_size: 5
