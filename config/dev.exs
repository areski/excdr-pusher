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
  level: :debug,
  format: "$time $metadata[$level] $levelpad$message\n"
  # metadata: [:file, :line]


# config :logger,
#   backends: [:console],
#   compile_time_purge_level: :debug

# config :logger, :console,
#   format: "\n$time $metadata[$level] $levelpad$message\n"

config :excdr_pusher,
  # Collect from
  sqlite_db: "./data/freeswitchcdr.db",
  # Push to
  postgres_dbname: "newfiesdb",
  postgres_host: "localhost",
  postgres_username: "postgres",
  postgres_password: "password",
  postgres_port: "5432",
  # Amount of CDRs to fetch every second
  # amount_cdr_fetch: 100
  amount_cdr_fetch: 2


#If you need to load configuration from the environment at runtime, you will need to do something like the following:
# my_setting = Application.get_env(:myapp, :setting) || System.get_env("MY_SETTING") || default_val
