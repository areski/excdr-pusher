defmodule Biller do
  use GenServer
  alias Decimal, as: D
  require Logger

  @moduledoc """
  This module implement the heartbeat to bill user by batch, rather than
  apply thousands of queries per seconds, we gather them cheaply in a process.
  We then do the sum calculation and apply this every seconds.

  Implement a simple key-value store as a server. This
  version creates a named server, so there is no need
  to pass the server pid to the API calls.
  """

  @doc """
  Create the key-value store. The optional parameter
  is a collection of key-value pairs which can be used to
  populate the store.
      iex> Biller.start []
      iex> Biller.add :userid_1, -2.05
      iex> Biller.get :userid_1
      "thomas"
      iex> Biller.stop
      :ok
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  # def start(default \\ []) do
  #   GenServer.start(__MODULE__, default, name: __MODULE__)
  # end

  # def start_link(state, opts \\ []) do
  #   GenServer.start_link(__MODULE__, state, opts)
  # end

  def init(args) do
    # Logger.error("-> init - args:#{inspect(args)}")
    Process.send_after(self(), :timeout_2sec, 1 * 2_000)
    {:ok, Enum.into(args, %{})}
  end

  # def init(state) do
  #   Logger.info("[init] start Biller... ")
  #   Process.send_after(self(), :timeout_2sec, 1 * 2_000)
  #   {:ok, state}
  # end

  def handle_info(:timeout_2sec, state) do
    Process.send_after(self(), :timeout_2sec, 1 * 2_000)
    cnt_user = state |> Enum.count()
    Logger.warn("Biller alive [cnt_user: #{cnt_user}]")
    # Flush DB here
    state = func_flush_db(state)
    {:noreply, state}
  end

  # catch for others handle info
  def handle_info(msg, state) do
    Logger.error("Biller: Got not expected handle_info: #{inspect(msg)}")
    {:ok, state}
  end

  def func_flush_db(state) do
    # Loop each user and run a DB query
    Enum.each(state, fn {user_atom, total_cost} ->
      # Logger.warn("user_id: #{user_atom} --> #{total_cost}")
      user_id = user_atom |> to_string |> String.split("_") |> Enum.fetch!(1) |> String.to_integer()
      cost_float = total_cost |> D.to_float()
      ExCdrPusher.DataUser.decrement_balance(user_id, cost_float)
    end)

    Enum.into([], %{})
  end

  @doc """
  Add or update the entry associated with key.
      iex> Biller.start user_1: 0.1
      iex> Biller.get :user_1
      0.1
      iex> Biller.add :user_1, 456
      iex> Biller.add :user_2, 0.2
      iex> Biller.get :user_1
      456
      iex> Biller.get :user_2
      0.2
      iex> Biller.stop
      :ok
  """
  def add(key, value) do
    GenServer.cast(__MODULE__, {:add, key, value})
  end

  def return_this, do: "THIS"

  @doc """
  Add the cost entry associated with user_id, user_id being an integer.
      iex> Biller.start
      iex> Biller.add_userid 1, 456
      iex> Biller.add_userid 2, 0.2
      iex> Biller.add_userid 3, ""
      iex> Biller.get :user_1
      456
      iex> Biller.get :user_2
      0.2
      iex> Biller.get :user_3
      ""
      iex> Biller.stop
      :ok
  """
  # Convert ID to atom userid_1
  def add_userid(user_id, value) when is_float(value),
    do: add(String.to_atom("userid_#{user_id}"), value)

  # Convert interger to float
  def add_userid(user_id, value) when is_integer(value),
    do: add(String.to_atom("userid_#{user_id}"), value / 1)

  # Convert string to float or 0
  def add_userid(user_id, value) when is_binary(value) do
    add(String.to_atom("userid_#{user_id}"), String.to_float(value))
  rescue
    _x ->
      add(String.to_atom("userid_#{user_id}"), 0.0)
  end

  @doc """
  Return the value associated with `key`, or `nil`
  is there is none.
      iex> Biller.start user_1: 0.1
      iex> Biller.get :user_1
      0.1
      iex> Biller.get :user_2
      nil
      iex> Biller.stop
      :ok
  """
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Return a sorted list of keys in the store.
      iex> Biller.start user_1: 0.1
      iex> Biller.keys
      [ :user_1 ]
      iex> Biller.add :user_2, 0.2
      iex> Biller.keys
      [ :user_1, :user_2 ]
      iex> Biller.keys
      [ :author, :user_1, :user_2 ]
      iex> Biller.stop
      :ok
  """

  def keys do
    GenServer.call(__MODULE__, {:keys})
  end

  @doc """
  Delete the entry corresponding to a key from the store

      iex> Biller.start user_1: 0.1
      iex> Biller.add :user_2, 0.2
      iex> Biller.keys
      [ :user_1, :user_2 ]
      iex> Biller.delete :user_1
      iex> Biller.keys
      [ :user_2 ]
      iex> Biller.delete :user_2
      iex> Biller.keys
      [ ]
      iex> Biller.delete :unknown
      iex> Biller.keys
      [ ]
      iex> Biller.stop
      :ok
  """

  def delete(key) do
    GenServer.cast(__MODULE__, {:remove, key})
  end

  @doc """
  Flush the user and push their usage to the database
  """
  def flush_db do
    GenServer.cast(__MODULE__, {:flush_db})
  end

  def stop do
    GenServer.stop(__MODULE__)
  end

  #######################
  # Server Implemention #
  #######################

  def handle_cast({:add, key, value}, state) do
    value =
      if Map.has_key?(state, key) do
        D.add(D.from_float(value), state[key])
      else
        D.from_float(value)
      end

    {:noreply, Map.put(state, key, value)}
  end

  def handle_cast({:flush_db}, state) do
    state = func_flush_db(state)
    {:noreply, state}
  end

  def handle_cast({:remove, key}, state) do
    {:noreply, Map.delete(state, key)}
  end

  def handle_call({:get, key}, _from, state) do
    {:reply, state[key], state}
  end

  def handle_call({:keys}, _from, state) do
    {:reply, Map.keys(state), state}
  end

  #########################
  # Catch the un-expected #
  #########################

  def terminate(_reason, state) do
    # Do Shutdown Stuff
    Logger.error(fn ->
      "terminate - going down - cp_id:#{inspect(state, charlists: :as_lists)}"
    end)

    Process.sleep(1000)
    :normal
  end

  # catch for others handle_event
  def handle_event(event, state) do
    Logger.error("Biller: Got not expected handle_event: #{inspect(event)}")
    {:ok, state}
  end
end
