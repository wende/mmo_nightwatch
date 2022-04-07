defmodule MmoNightwatch.HeroState do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{name: _name, position: _position} = state) do
    {:ok, Map.merge(state, %{alive: true})}
  end

  def get_position(pid) do
    GenServer.call(pid, :get_position)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def die(pid) do
    GenServer.cast(pid, :die)
  end

  def respawn(pid) do
    GenServer.cast(pid, :respawn)
  end

  def move(pid, new_position) do
    GenServer.cast(pid, {:move, new_position})
  end

  def handle_call(:get_position, _, state) do
    {:reply, state.position, state}
  end

  def handle_call(:get_state, _, state) do
    {:reply, state, state}
  end

  def handle_cast({:move, new_position}, state) do
    {:noreply, %{state | position: new_position}}
  end

  def handle_cast(:die, state) do
    {:noreply, %{state | alive: false}}
  end

  def handle_cast(:respawn, state) do
    {:noreply, %{state | alive: true}}
  end
end
