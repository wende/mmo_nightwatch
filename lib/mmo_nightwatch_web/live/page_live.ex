defmodule MmoNightwatchWeb.PageLive do
  use MmoNightwatchWeb, :live_view

  alias MmoNightwatch.GameState
  alias MmoNightwatch.HeroState
  alias MmoNightwatch.LiveMonitor

  @tick 30

  @names """
         Ashwin Madden
         Ernie Singh
         Mariana Neale
         Sameera Lam
         Zahraa Dunn
         Shayaan Roman
         Aditi Lindsey
         Deacon Andrews
         Amman Guerra
         Gertrude Valentine
         """
         |> String.trim()
         |> String.split("\n")

  def render(assigns) do
    heroes =
      Enum.map(assigns.state.heroes, fn {k, v} ->
        {k, HeroState.get_state(v)}
      end)
      |> Enum.into(%{})

    ~H"""
    <div id="Title" style="position: relative">
    WASD To Move. E to attack
    </div>
    <div class="main-container" phx-window-keydown="keydown" style="position: relative">
    <%= for {{x, y}, content} <- @state.board.tiles do %>
      <div
      style={"display: block;
              position: absolute;
              left: #{x * 50}px;
              top: #{y * 50}px;
              background-color: #{ color(content) };
              width: 50px;
              height: 50px;"}
      ></div>
    <% end %>
    <%= for {name, %{position: {x, y}, alive: alive}} <- heroes, name != @name do %>
      <div
      style={"display: block;
              position: absolute;
              left: #{x * 50 + 10}px;
              top: #{y * 50 + 10}px;
              text-decoration: #{ if alive, do: "default", else: "line-through" };
              background-color: red ;
              color: black;
              width: 30px;
              height: 30px;"}>
      <%= name %> </div>
    <% end %>
    <div style={"display: block;
              position: absolute;
              left: #{elem(Map.get(heroes, @name).position, 0) * 50 + 10}px;
              top: #{elem(Map.get(heroes, @name).position, 1) * 50 + 10}px;
              background-color: blue ;
              color: white;
              z-index: 1;
              width: 30px;
              height: 30px;"}>
              <%= @name %>
    </div>
    </div>
    """
  end

  defp color(:wall), do: "black"
  defp color({:hero, _}), do: "red"
  defp color(_), do: "pink"

  def mount(params, _session, socket) do
    name = params["hero"] || Enum.random(@names)
    LiveMonitor.monitor(self(), __MODULE__, name)
    {:ok, pid, {_x, _y}} = GameState.ensure_hero(name)

    # Link to the hero genserver so that it dies with this WebSocket and vice versa
    Process.link(pid)
    Process.monitor(GameState)

    if connected?(socket) do
      Process.send_after(self(), :tick, 100)
    end

    {:ok, assign(socket, name: name, time: "", state: GameState.get_state())}
  end

  def unmount(name, _reason) do
    :ok = GameState.remove_hero(name)
  end

  def handle_event("keydown", %{"key" => key}, socket) do
    {:noreply, key_down(socket, key)}
  end

  def key_down(socket, key) do
    case key do
      "w" -> :ok = GameState.move_hero(socket.assigns.name, :up)
      "s" -> :ok = GameState.move_hero(socket.assigns.name, :down)
      "a" -> :ok = GameState.move_hero(socket.assigns.name, :left)
      "d" -> :ok = GameState.move_hero(socket.assigns.name, :right)
      "e" -> :ok = GameState.attack(socket.assigns.name)
      "r" -> :ok = GameState.exit()
      _ -> :ok
    end

    socket
  end

  def handle_info({:DOWN, _ref, :process, _pid, _reason}, state) do
    Process.exit(self(), :normal)
    {:noreply, state}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, @tick)
    {:noreply, assign(socket, state: GameState.get_state(), time: DateTime.utc_now())}
  end
end
