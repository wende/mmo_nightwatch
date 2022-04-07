defmodule MmoNightwatch.GameStateTest do
  use ExUnit.Case, async: false

  alias MmoNightwatch.GameState
  alias MmoNightwatch.HeroState
  alias MmoNightwatch.Board

  setup do
    GameState.start_link([])

    on_exit(fn ->
      Process.exit(Process.whereis(GameState), :normal)
    end)
  end

  test "Spawns and despawns heroes" do
    hero = get_rand_name()
    {:ok, pid, _pos} = GameState.ensure_hero(hero)
    state = GameState.get_state()
    assert state.heroes[hero]
    assert Process.alive?(pid)

    GameState.remove_hero(hero)
    state = GameState.get_state()
    refute state.heroes[hero]
    refute Process.alive?(pid)
  end

  test "Can move heroes" do
    board = GameState.get_state().board
    hero = get_rand_name()
    {:ok, pid, {x, y}} = GameState.ensure_hero(hero)
    :ok = GameState.move_hero(hero, :up)

    # Do a call to make sure the previous message was proccessed and prevent race conditions
    _ = GameState.get_state()

    new_position = HeroState.get_state(pid).position
    assert Board.up(board, {x, y}) == new_position
  end

  test "Can kill heroes and respawn them" do
    hero = get_rand_name()
    hero2 = get_rand_name()

    {:ok, pid, pos} = GameState.ensure_hero(hero)
    {:ok, pid2, pos2} = GameState.ensure_hero(hero2)

    # Cheat the location of hero nr2 to be anywhere in hero1 vicinity
    adj = Board.get_adjacent(GameState.get_state().board, pos) |> Enum.random()
    :sys.replace_state(pid2, fn state -> %{state | position: adj} end)
    assert HeroState.get_state(pid2).position != pos2

    GameState.attack(hero2)
    # Do a call to make sure the previous message was proccessed and prevent race conditions
    _ = GameState.get_state()
    refute HeroState.get_state(pid).alive

    :timer.sleep(GameState.respawn_timeout() + 10)
  end

  defp get_rand_name() do
    "testhero#{Enum.random(1..100_000)}"
  end
end
