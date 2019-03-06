defmodule ExCdrPusher.Repo do
  use Ecto.Repo,
    otp_app: :excdr_pusher,
    adapter: Ecto.Adapters.Postgres
end
