defmodule ExCdrPusher do
  use Application

  @moduledoc """
  Module to create the supervisor for the main application
  """

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: ExCdrPusher.Worker.start_link(arg1, ...)
      # worker(ExCdrPusher.Worker, [arg1, arg2, arg3]),
      supervisor(ExCdrPusher.Repo, []),
      worker(Collector, [[], [name: MyCollector]]),
      worker(PusherPG, [0]),
      # worker(PushInfluxDB, [0]),
      # `Sqlitex.Server` is not used as it's not possible to catch errors on
      # reading / opening the database
      # worker(Sqlitex.Server, [
      #   Application.fetch_env!(:excdr_pusher, :sqlite_db),
      #   [name: Sqlitex.Server]]),
      # ExCdrPusher.InConnection.child_spec,
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [
      strategy: :one_for_one, max_restarts: 100,
      max_seconds: 5, name: ExCdrPusher.Supervisor
    ]
    Supervisor.start_link(children, opts)

  end
end
