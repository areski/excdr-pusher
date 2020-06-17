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
  path: "/tmp/error.log",
  level: :warn,
  format: "$date $time $metadata[$level] $levelpad$message\n"

# configuration for the {LoggerFileBackend, :debug_log} backend
config :logger, :debug_log,
  path: "/tmp/debug.log",
  level: :info,
  format: "$date $time $metadata[$level] $levelpad$message\n"

config :excdr_pusher,
  sqlite_db: "./data/freeswitchcdr-test.db",
  tick_frequency: 1000,
  amount_cdr_fetch: 1,
  enable_billing: true

# Push to
config :excdr_pusher, ecto_repos: [ExCdrPusher.Repo]

config :excdr_pusher, ExCdrPusher.Repo,
  url: "postgres://postgres:password@localhost/newfiesdb",
  pool_size: 10,
  pool: Ecto.Adapters.SQL.Sandbox
