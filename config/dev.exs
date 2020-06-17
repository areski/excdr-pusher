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
  sqlite_db: "./private/freeswitchcdr.db",
  # sqlite_db: "/tmp/new_fscdr_db.db",
  tick_frequency: 200,
  amount_cdr_fetch: 1,
  enable_billing: true

# Push to
config :excdr_pusher, ecto_repos: [ExCdrPusher.Repo]

config :excdr_pusher, ExCdrPusher.Repo,
  url: "postgres://postgres:password@localhost/newfiesdb",
  pool_size: 10

# If you need to load configuration from the environment at runtime, you will
# need to do something like the following:
# my_setting = Application.get_env(:myapp, :setting) ||
#     System.get_env("MY_SETTING") || default_val
