defmodule MmoNightwatch.Board do
  alias __MODULE__

  @adjacent for x <- -1..1, y <- -1..1, do: {x, y}
  @type field :: {integer, integer}
  @type t :: %__MODULE__{
          width: pos_integer(),
          height: pos_integer(),
          tiles: %{{integer, integer} => any()}
        }
  defstruct width: 0, height: 0, tiles: %{}

  def new(width, height) do
    tiles =
      for x <- 0..width, y <- 0..height do
        if(:rand.uniform() < 0.2) do
          {{x, y}, :wall}
        else
          {{x, y}, nil}
        end
      end

    %Board{width: width, height: height, tiles: Map.new(tiles)}
  end

  @spec get_adjacent(Board.t(), {x :: integer, y :: integer}) :: [{}]
  def get_adjacent(board = %Board{}, {x, y}) do
    @adjacent
    |> Enum.map(fn {dx, dy} -> field(board, x + dx, y + dy) end)
    |> Enum.uniq()
  end

  def field(%Board{width: width, height: height}, x, y) do
    {max(0, min(width, x)), max(0, min(height, y))}
  end

  def put(board, x, y, tile) do
    put_in(board, [:tiles, Access.key({x, y})], tile)
  end

  def up(board = %Board{}, {x, y}), do: move(board, {x, y}, {0, -1})
  def down(board = %Board{}, {x, y}), do: move(board, {x, y}, {0, 1})
  def left(board = %Board{}, {x, y}), do: move(board, {x, y}, {-1, 0})
  def right(board = %Board{}, {x, y}), do: move(board, {x, y}, {1, 0})

  def move(board = %Board{}, {x, y}, {dx, dy}) do
    if(walkable(board, {x + dx, y + dy})) do
      field(board, x + dx, y + dy)
    else
      field(board, x, y)
    end
  end

  def walkable(board, {x, y}) do
    board.tiles[{x, y}] != :wall
  end
end
