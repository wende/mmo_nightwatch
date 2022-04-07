defmodule MmoNightwatch.LiveMonitor do
  use GenServer

  def start_link([]) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def monitor(pid, view_module, meta) do
    GenServer.call(__MODULE__, {:monitor, pid, view_module, meta})
  end

  def init(_) do
    {:ok, %{views: %{}}}
  end

  def handle_call({:monitor, pid, view_module, meta}, _, %{views: views} = state) do
    Process.monitor(pid)
    {:reply, :ok, %{state | views: Map.put(views, pid, {view_module, meta})}}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    {{module, meta}, new_views} = Map.pop(state.views, pid)
    # should wrap in isolated task or rescue from exception
    module.unmount(meta, reason)
    {:noreply, %{state | views: new_views}}
  end
end
