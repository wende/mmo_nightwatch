defmodule MmoNightwatch.Board do
  @moduledoc """
  Structure and its coresponding functions responsible for respresenting dimensions of the game
  as well as the boundary rules and pseudo-distance adjacency.
  """
  alias __MODULE__

  @adjacent for x <- -1..1, y <- -1..1, do: {x, y}
  @type field :: {integer, integer}
  @type t :: %__MODULE__{
          width: pos_integer(),
          height: pos_integer(),
          tiles: %{{integer, integer} => any()}
        }
  defstruct width: 0, height: 0, tiles: %{}

  @doc """
  Creates a board with set dimensions
  """
  @spec new(integer(), integer) :: __MODULE__.t()
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

  @doc """
  Returns adjacent fields to a set coordinate. The coordinate itself is also considered adjacent.
  Coordinates outside of board boundaries are not included in the returned value
  """
  @spec get_adjacent(Board.t(), {x :: integer, y :: integer}) :: [{}]
  def get_adjacent(board = %Board{}, {x, y}) do
    @adjacent
    |> Enum.map(fn {dx, dy} -> field(board, x + dx, y + dy) end)
    |> Enum.uniq()
  end

  @doc """
  Returns a safe tuple inside of board boundaries based on coordinates.
  If coordinates exceed board boundaries a closest possible value is returned instead
  """
  @spec field(Board.t(), integer(), integer()) :: {integer(), integer()}
  def field(%Board{width: width, height: height}, x, y) do
    {max(0, min(width, x)), max(0, min(height, y))}
  end

  @doc """
  Inserts any value at specified board coordinates
  """
  @spec put(Board.t(), {integer(), integer()}, any()) :: Board.t()
  def put(board, {x, y}, tile) do
    put_in(board, [:tiles, Access.key({x, y})], tile)
  end

  @spec up(Board.t(), {integer(), integer()}) :: {integer(), integer()}
  def up(board = %Board{}, {x, y}), do: move(board, {x, y}, {0, -1})

  @spec down(Board.t(), {integer(), integer()}) :: {integer(), integer()}
  def down(board = %Board{}, {x, y}), do: move(board, {x, y}, {0, 1})

  @spec left(Board.t(), {integer(), integer()}) :: {integer(), integer()}
  def left(board = %Board{}, {x, y}), do: move(board, {x, y}, {-1, 0})

  @spec right(Board.t(), {integer(), integer()}) :: {integer(), integer()}
  def right(board = %Board{}, {x, y}), do: move(board, {x, y}, {1, 0})

  @doc """
  Returns a new field if it is walkable and inside board bounderies.
  Otherwise returns the old field unchanged
  """
  @spec move(Board.t(), {integer(), integer()}, {integer(), integer()}) :: {integer(), integer()}
  def move(board = %Board{}, {x, y}, {dx, dy}) do
    if(walkable(board, {x + dx, y + dy})) do
      field(board, x + dx, y + dy)
    else
      field(board, x, y)
    end
  end

  @doc """
  Placeholder function to check if a tile is considered walkable
  """
  @spec walkable(Board.t(), {integer(), integer()}) :: boolean()
  def walkable(board, {x, y}) do
    board.tiles[{x, y}] != :wall
  end

  @doc """
  Returns a random position within boards boundaries
  """
  @spec get_random_position(Board.t()) :: {integer(), integer()}
  def get_random_position(board) do
    randx = floor(:rand.uniform() * board.width)
    randy = floor(:rand.uniform() * board.height)

    {randx, randy}
  end
end
