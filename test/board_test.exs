defmodule MmoNightwatch.BoardTest do
  use ExUnit.Case
  alias MmoNightwatch.Board

  @board %Board{width: 10, height: 10}
  test "Gives proper adjacent fields" do
    assert Board.get_adjacent(@board, 5, 5) ==
             [{4, 4}, {4, 5}, {4, 6}, {5, 4}, {5, 5}, {5, 6}, {6, 4}, {6, 5}, {6, 6}]

    assert Board.get_adjacent(@board, 0, 0) == [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  end
end
