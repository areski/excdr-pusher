defmodule ExCdrPusher.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    log_app_info()

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(ExCdrPusher.Repo, []),
      worker(Collector, [[], [name: MyCollector]]),
      worker(PusherPG, [0]),
      worker(Biller, []),
      # `Sqlitex.Server` is not used as it's not possible to catch opening db errors
      worker(Sqlitex.Server, [
        Application.fetch_env!(:excdr_pusher, :sqlite_db),
        [name: Sqlitex.DB]
      ])
    ]

    opts = [
      strategy: :one_for_one,
      max_restarts: 100,
      max_seconds: 5,
      name: ExCdrPusher.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

  @doc """
  log_app_info will log Application information such as version and some settings
  """
  def log_app_info do
    {:ok, vsn} = :application.get_key(:excdr_pusher, :vsn)
    app_version = List.to_string(vsn)
    {_, _, ex_ver} = List.keyfind(:application.which_applications(), :elixir, 0)
    erl_version = :erlang.system_info(:otp_release)
    sqlite_db = Application.fetch_env!(:excdr_pusher, :sqlite_db)

    Logger.error("========================================================")

    Logger.error(
      "[starting] excdr_pusher (app_version:#{app_version} - " <>
        "ex_ver:#{ex_ver} - erl_version:#{erl_version})"
    )

    tick_freq = Application.fetch_env!(:excdr_pusher, :tick_frequency)
    Logger.error("[config] tick_freq:#{tick_freq}")
    Logger.error("[sqlite_db: #{sqlite_db}]")
  end
end
