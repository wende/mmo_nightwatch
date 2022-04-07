defmodule MmoNightwatch.GameState do
  @moduledoc """
  GenServer responsible for all highest level decision about game session.
  It serves as an intermediary between the end user and game rules, as well as
  logic coordinator in interactions between MmoNightwatch.HeroState GenServers
  """

  alias MmoNightwatch.Board
  alias MmoNightwatch.GameSupervisor
  alias MmoNightwatch.HeroState

  use GenServer
  @type t() :: %__MODULE__{board: Board.t() | nil, heroes: %{String.t() => pid}}
  defstruct board: nil, heroes: %{}

  @spec board_width() :: integer()
  def board_width(),
    do: Application.fetch_env!(:mmo_nightwatch, MmoNightwatch.GameState)[:board_width]

  @spec board_height() :: integer()
  def board_height(),
    do: Application.fetch_env!(:mmo_nightwatch, MmoNightwatch.GameState)[:board_height]

  @spec respawn_timeout() :: integer()
  def respawn_timeout(),
    do: Application.fetch_env!(:mmo_nightwatch, MmoNightwatch.GameState)[:respawn_timeout]

  @spec get_state() :: __MODULE__.t()
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  @doc """
  Ensures hero exists. If it does, returns the existing pid of a hero and its position.
  If it doesn't creates a new hero at a random position and returns its pid and position
  """
  @spec ensure_hero(String.t()) :: {:ok, pid(), {integer(), integer()}}
  def ensure_hero(name) do
    GenServer.call(__MODULE__, {:ensure_hero, name})
  end

  @doc """
  Removes the hero from the board and cleans up all the processes
  """
  @spec remove_hero(String.t()) :: :ok
  def remove_hero(name) do
    GenServer.cast(__MODULE__, {:remove_hero, name})
  end

  @doc """
  Moves a hero in one of four directions. Updates heroes internal state
  """
  @spec move_hero(String.t(), :up | :down | :left | :right) :: :ok
  def move_hero(name, direction) do
    GenServer.cast(__MODULE__, {:move_hero, name, direction})
  end

  @doc """
  Attacks all heroes in adjacent tiles to the casting hero.
  Attacked heroes die chaning their state of alive to false
  Dead heroes respawn after a timeout set in config
  """
  @spec attack(String.t()) :: :ok
  def attack(name) do
    GenServer.cast(__MODULE__, {:attack, name})
  end

  ## Callbacks

  @spec start_link([]) :: :ignore | {:error, any} | {:ok, pid}
  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @spec init(any) :: {:ok, __MODULE__.t()}
  def init(_) do
    {:ok,
     %__MODULE__{
       board: Board.new(board_width(), board_height()),
       heroes: %{}
     }}
  end

  @spec exit :: :ok
  def exit() do
    GenServer.stop(__MODULE__, :kill)
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_call({:ensure_hero, hero}, _, state) do
    if(Map.has_key?(state.heroes, hero) && Process.alive?(state.heroes[hero])) do
      pid = state.heroes[hero]
      {x, y} = HeroState.get_position(pid)
      {:reply, {:ok, pid, {x, y}}, state}
    else
      {x, y} = Board.get_random_position(state.board)
      {:ok, pid} = GameSupervisor.start_hero(%{name: hero, position: {x, y}})

      {:reply, {:ok, pid, {x, y}}, put_in(state.heroes[hero], pid)}
    end
  end

  def handle_cast({:remove_hero, hero}, state) do
    :ok = GameSupervisor.stop_hero(state.heroes[hero])
    {:noreply, %{state | heroes: Map.delete(state.heroes, hero)}}
  end

  def handle_cast({:move_hero, hero, direction}, state) do
    pid = state.heroes[hero]
    hero_state = HeroState.get_state(pid)

    new_position =
      if hero_state.alive do
        case direction do
          :up -> Board.up(state.board, hero_state.position)
          :down -> Board.down(state.board, hero_state.position)
          :right -> Board.right(state.board, hero_state.position)
          :left -> Board.left(state.board, hero_state.position)
          _ -> state.heroes[hero]
        end
      else
        hero_state.position
      end

    :ok = HeroState.move(pid, new_position)

    {:noreply, state}
  end

  def handle_cast({:attack, hero}, state) do
    hero_state = HeroState.get_state(state.heroes[hero])

    if hero_state.alive do
      adjacents = Board.get_adjacent(state.board, hero_state.position)

      state.heroes
      |> Enum.map(&HeroState.get_state(elem(&1, 1)))
      |> Enum.filter(fn %{name: victim, position: pos} -> victim != hero && pos in adjacents end)
      |> Enum.each(fn %{name: victim, alive: alive} ->
        if(alive) do
          :timer.send_after(respawn_timeout(), self(), {:respawn, victim})
          :ok = HeroState.die(state.heroes[victim])
        end
      end)
    end

    {:noreply, state}
  end

  def handle_info({:respawn, hero}, state) do
    pid = state.heroes[hero]
    :ok = HeroState.respawn(pid)
    :ok = HeroState.move(pid, Board.get_random_position(state.board))
    {:noreply, state}
  end
end
