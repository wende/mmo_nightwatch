defmodule MmoNightwatch.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      # MmoNightwatch.Repo,
      # Start the Telemetry supervisor
      MmoNightwatchWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: MmoNightwatch.PubSub},
      # Start the Endpoint (http/https)
      MmoNightwatchWeb.Endpoint,
      # Start a worker by calling: MmoNightwatch.Worker.start_link(arg)
      {MmoNightwatch.GameState, name: MmoNightwatch.GameState}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MmoNightwatch.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MmoNightwatchWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
