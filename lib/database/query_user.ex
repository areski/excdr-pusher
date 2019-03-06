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

  ### Memoized functions

  # Cached function get_userprofile
  defmemo c__get_userprofile(user_id), expires_in: 1 * 10_000 do
    query =
      from(
        up in SchemaUserProfile,
        where: up.user_id == ^user_id,
        select: up
      )

    case Repo.all(query) do
      [result] ->
        result

      [] ->
        false
    end
  end
end
