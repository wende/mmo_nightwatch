defmodule MmoNightwatch.GameState do
  alias MmoNightwatch.Board
  alias MmoNightwatch.GameSupervisor
  alias MmoNightwatch.HeroState

  use GenServer

  @respawn_timeout 5000

  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    {:ok,
     %{
       board: Board.new(20, 20),
       heroes: %{}
     }}
  end

  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  def ensure_hero(name) do
    GenServer.call(__MODULE__, {:ensure_hero, name})
  end

  def remove_hero(name) do
    GenServer.cast(__MODULE__, {:remove_hero, name})
  end

  def move_hero(name, direction) do
    GenServer.cast(__MODULE__, {:move_hero, name, direction})
  end

  def attack(name) do
    GenServer.cast(__MODULE__, {:attack, name})
  end

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
          :timer.send_after(@respawn_timeout, self(), {:respawn, victim})
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
