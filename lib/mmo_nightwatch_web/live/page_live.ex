defmodule MmoNightwatchWeb.PageLive do
  use MmoNightwatchWeb, :live_view
  alias MmoNightwatch.GameState

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
    ~H"""
    <div id="Title" style="position: relative">
    <%= @time %>
    <%= @key %>
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
    <%= for {name, {x, y}} <- @state.heroes do %>
      <div
      style={"display: block;
              position: absolute;
              left: #{x * 50 + 10}px;
              top: #{y * 50 + 10}px;
              background-color: red ;
              color: black;
              width: 30px;
              height: 30px;"}
      > <%= name %> </div>
    <% end %>
    <div style={"display: block;
              position: absolute;
              left: #{elem(@state.heroes[@name], 0) * 50 + 10}px;
              top: #{elem(@state.heroes[@name], 1) * 50 + 10}px;
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

    if connected?(socket) do
      Process.send_after(self(), :tick, 100)
    end

    :ok = GameState.ensure_hero(name)

    {:ok, assign(socket, name: name, time: "10:00", key: "None", state: GameState.get_state())}
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
      " " -> :ok = GameState.attack(socket.assigns.name)
      _ -> :ok
    end

    socket
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 100)
    {:noreply, assign(socket, state: GameState.get_state(), time: DateTime.utc_now())}
  end
end
