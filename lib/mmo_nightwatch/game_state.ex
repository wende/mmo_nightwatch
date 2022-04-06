defmodule MmoNightwatch.GameState do
  alias MmoNightwatch.Board
  use GenServer

  @respawn_timeout 5000

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, %{}, name: name)
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

  def move_hero(name, direction) do
    GenServer.call(__MODULE__, {:move_hero, name, direction})
  end

  def attack(name) do
    GenServer.call(__MODULE__, {:attack, name})
  end

  def exit() do
    GenServer.stop(__MODULE__, :kill)
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_call({:ensure_hero, hero}, _, state) do
    if(Map.has_key?(state.heroes, hero)) do
      {:reply, :ok, state}
    else
      {:reply, :ok, spawn_hero(state, hero)}
    end
  end

  def handle_call({:move_hero, hero, direction}, _, state) do
    new_position =
      if state.heroes[hero].alive do
        case direction do
          :up -> Board.up(state.board, state.heroes[hero].pos)
          :down -> Board.down(state.board, state.heroes[hero].pos)
          :right -> Board.right(state.board, state.heroes[hero].pos)
          :left -> Board.left(state.board, state.heroes[hero].pos)
          _ -> state.heroes[hero]
        end
      else
        state.heroes[hero].pos
      end

    {:reply, :ok, put_in(state, [:heroes, Access.key(hero), :pos], new_position)}
  end

  def handle_call({:attack, hero}, _, state) do
    adjacents = Board.get_adjacent(state.board, state.heroes[hero].pos)

    new_state =
      state.heroes
      |> Enum.filter(fn {victim, %{pos: pos}} -> victim != hero && pos in adjacents end)
      |> IO.inspect()
      |> Enum.reduce(
        state,
        fn {victim, _}, state_acc ->
          :timer.send_after(@respawn_timeout, self(), {:respawn, victim})
          put_in(state_acc, [:heroes, Access.key(victim), :alive], false)
        end
      )

    {:reply, :ok, new_state}
  end

  def handle_info({:respawn, hero}, state) do
    {:noreply, spawn_hero(state, hero)}
  end

  defp spawn_hero(state, name) do
    randx = floor(:rand.uniform() * state.board.width)
    randy = floor(:rand.uniform() * state.board.height)

    %{state | heroes: Map.put(state.heroes, name, %{pos: {randx, randy}, alive: true})}
  end
end
