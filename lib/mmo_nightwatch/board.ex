defmodule MmoNightwatch.Board do
  alias __MODULE__

  @adjacent for x <- -1..1, y <- -1..1, do: {x, y}
  @type field :: {integer, integer}
  @type t :: %__MODULE__{width: pos_integer(), height: pos_integer()}
  defstruct width: 0, height: 0

  @spec get_adjacent(Board.t(), x :: integer, y :: integer) :: [{}]
  def get_adjacent(board = %Board{}, x, y) do
    @adjacent
    |> Enum.map(fn {dx, dy} -> field(board, x + dx, y + dy) end)
    |> Enum.uniq()
  end

  def field(%Board{width: width, height: height}, x, y) do
    {max(0, min(width, x)), max(0, min(height, y))}
  end
end
