defmodule MmoNightwatch.BoardTest do
  use ExUnit.Case
  alias MmoNightwatch.Board

  @board_dim 10
  @board %Board{width: @board_dim, height: @board_dim}
  test "Gives proper adjacent fields" do
    assert Board.get_adjacent(@board, {5, 5}) ==
             [{4, 4}, {4, 5}, {4, 6}, {5, 4}, {5, 5}, {5, 6}, {6, 4}, {6, 5}, {6, 6}]

    assert Board.get_adjacent(@board, {0, 0}) == [{0, 0}, {0, 1}, {1, 0}, {1, 1}]
  end

  test "Respects bounds when moving" do
    assert Board.up(@board, {1, 1}) == {1, 0}
    assert Board.up(@board, {1, 0}) == {1, 0}

    assert Board.down(@board, {1, @board_dim - 1}) == {1, @board_dim}
    assert Board.down(@board, {1, @board_dim}) == {1, @board_dim}

    assert Board.left(@board, {1, 1}) == {0, 1}
    assert Board.left(@board, {0, 0}) == {0, 0}

    assert Board.right(@board, {@board_dim - 1, 1}) == {@board_dim, 1}
    assert Board.right(@board, {@board_dim, 0}) == {@board_dim, 0}

    assert Board.field(@board, 100_000, 100_000) == {@board_dim, @board_dim}
    assert Board.field(@board, -100, -100) == {0, 0}
  end
end
