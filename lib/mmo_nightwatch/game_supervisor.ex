defmodule MmoNightwatch.GameSupervisor do
  @moduledoc """
  Supervisor responsible for separating game session concerns from the rest of the supervision tree
  """
  use Supervisor

  @spec start_link(any) :: :ignore | {:error, any} | {:ok, pid}
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

  @doc """
  Start a child process of HeroState type
  """
  @spec start_hero(any) :: :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_hero(opts) do
    DynamicSupervisor.start_child(MmoNightwatch.HeroSupervisor, {MmoNightwatch.HeroState, opts})
  end

  @spec stop_hero(pid) :: :ok | {:error, :not_found}
  def stop_hero(pid) do
    DynamicSupervisor.terminate_child(MmoNightwatch.HeroSupervisor, pid)
  end
end
