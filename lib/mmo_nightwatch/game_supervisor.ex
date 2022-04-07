defmodule MmoNightwatch.GameSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    children = [
      MmoNightwatch.GameState,
      {DynamicSupervisor, strategy: :one_for_one, name: MmoNightwatch.HeroSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def start_hero(opts) do
    DynamicSupervisor.start_child(MmoNightwatch.HeroSupervisor, {MmoNightwatch.HeroState, opts})
  end

  def stop_hero(pid) do
    DynamicSupervisor.terminate_child(MmoNightwatch.HeroSupervisor, pid)
  end
end
