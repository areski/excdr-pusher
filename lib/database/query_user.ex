defmodule ExCdrPusher.DataUser do
  import Ecto.Query, only: [from: 2]
  # import Ecto.Query.API, only: [fragment: 1]
  alias DUtils
  alias ExCdrPusher.Repo
  alias ExCdrPusher.SchemaUserProfile
  use Memoize
  require Logger

  @moduledoc """
  Query helper
  """

  @doc """
  Get userprofile details

  >> ExCdrPusher.DataUser.get_userprofile(170)
  """
  def get_userprofile(nil), do: false
  def get_userprofile(user_id) do
    query =
      from(
        up in SchemaUserProfile,
        where: up.user_id == ^user_id,
        select: up
      )

    Repo.all(query)

    case Repo.all(query) do
      [result] ->
        result

      [] ->
        false
    end
  end

  @doc """
  Decrement Balance

  >> ExCdrPusher.DataUser.decrement_balance(1, 0.51531)
  """
  def decrement_balance(user_id, cost) do
    Logger.error("-> decrement_balance user_id:#{user_id} - cost:#{cost}")
    SchemaUserProfile
    |> Ecto.Query.where([p], p.user_id == ^user_id)
    |> Repo.update_all(inc: [balance: -cost])

    # Repo.get_by(SchemaUserProfile, user_id: 1)
    # |> Ecto.Changeset.change(balance: balance)
    # |> Repo.update()

    # # Repo.update(change(alice, balance: alice.balance - 10))
    # # userp = Repo.get!(SchemaUserProfile, user_id)
    # userp = Repo.get_by!(SchemaUserProfile, user_id: user_id)
    # user_change = Ecto.Changeset.change userp, balance: userp - cost
    # case Repo.update user_change do
    #   {:ok, struct}       -> # Updated with success
    #     Logger.error("-> struct:#{struct}")

    #   {:error, changeset} -> # Something went wrong
    #     Logger.error("-> changeset:#{changeset}")
    # end
  end

  ### Memoized functions

  # Cached function get_userprofile
  defmemo c__get_userprofile(user_id), expires_in: 1 * 10_000 do
    get_userprofile(user_id)
  end
end
