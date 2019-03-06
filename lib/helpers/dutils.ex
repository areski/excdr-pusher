defmodule DUtils do
  @moduledoc """
  Utilities module, compiling misc of functions
  """

  @doc """
  method to retrieve the current time in Time
  https://hexdocs.pm/elixir/Time.html#content
  """
  def current_time do
    {_, ctime} = :os.timestamp() |> :calendar.now_to_local_time()
    {:ok, ftime} = ctime |> Time.from_erl()
    ftime
  end
end
