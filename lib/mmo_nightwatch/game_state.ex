defmodule MmoNightwatch.GameState do
  alias MmoNightwatch.Board
  use GenServer

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

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_call({:ensure_hero, hero}, _, state) do
    if(Map.has_key?(state.heroes, hero)) do
      {:reply, :ok, state}
    else
      {:reply, :ok, new_hero(state, hero)}
    end
  end

  def handle_call({:move_hero, hero, direction}, _, state) do
    new_position =
      case direction do
        :up -> Board.up(state.board, state.heroes[hero])
        :down -> Board.down(state.board, state.heroes[hero])
        :right -> Board.right(state.board, state.heroes[hero])
        :left -> Board.left(state.board, state.heroes[hero])
        _ -> state.heroes[hero]
      end

    {:reply, :ok, %{state | heroes: Map.put(state.heroes, hero, new_position)}}
  end

  defp new_hero(state, name) do
    randx = floor(:rand.uniform() * state.board.width)
    randy = floor(:rand.uniform() * state.board.height)

    %{state | heroes: Map.put(state.heroes, name, {randx, randy})}
  end
end
