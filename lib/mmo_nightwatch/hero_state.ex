defmodule MmoNightwatch.HeroState do
  @moduledoc """
  GenServer responsible for representing and holding key information about the players/heroes of the game.
  """
  use GenServer

  @type t() :: %__MODULE__{
          position: {integer(), integer()},
          name: String.t(),
          alive: boolean()
        }
  defstruct position: nil, name: nil, alive: true

  @doc """
  Returns the position of this hero
  """
  @spec get_position(pid()) :: {integer(), integer()}
  def get_position(pid) do
    GenServer.call(pid, :get_position)
  end

  @spec get_state(pid()) :: __MODULE__.t()
  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end


  @doc """
  Changes the state of 'alive' to false, regardless of its value. Nonblocking
  """
  @spec die(pid()) :: :ok
  def die(pid) do
    GenServer.cast(pid, :die)
  end

  @doc """
  Changes the state of 'alive' to true, regardless of its value. Nonblocking
  """
  @spec respawn(pid()) :: :ok
  def respawn(pid) do
    GenServer.cast(pid, :respawn)
  end

  @doc """
  Changes the state of position to a new tuple, regardless of its value. Nonblocking
  """
  @spec move(pid(), {integer(), integer()}) :: :ok
  def move(pid, new_position) do
    GenServer.cast(pid, {:move, new_position})
  end

  ## Callbacks

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @spec init(%{:name => String.t(), :position => {integer(), integer()}}) ::
          {:ok, %{:alive => true, :name => any, :position => any}}
  def init(%{name: name, position: {x, y}} = state) when is_binary(name) and is_integer(x) and is_integer(y) do
    {:ok, Map.merge(state, %{alive: true})}
  end

  def handle_call(:get_position, _, state) do
    {:reply, state.position, state}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:move, new_position}, state) do
    {:noreply, %{state | position: new_position}}
  end

  def handle_cast(:die, state) do
    {:noreply, %{state | alive: false}}
  end

  def handle_cast(:respawn, state) do
    {:noreply, %{state | alive: true}}
  end
end
