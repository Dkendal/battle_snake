defmodule BattleSnake.GameChannel do
  alias BattleSnake.{World, GameServer, GameForm}

  use BattleSnake.Web, :channel

  @spec join(binary, %{}, Phoenix.Socket.t) ::
  {:ok, Phoenix.Socket.t} |
  {:error, any}
  def join("game:" <> game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_id, game_id)

      channel_pid = self()

      callback = fn s ->
        send channel_pid, {:render, s.world}
      end

      with({:ok, game_form} <- load_game_form(game_id),
           {:ok, game_server_pid} <- load_game_server_pid(game_form, callback),
           send(self(), :after_join),
        do: {:ok,
             socket
             |> assign(:game_server_pid, game_server_pid)
             |> assign(:game_form, game_form)})
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("start", _, socket) do
    game_server_pid = socket.assigns.game_server_pid
    :ok = GameServer.resume(game_server_pid)
    {:reply, :ok, socket}
  end

  def load_game_form(game_id) do
    GameForm.get(game_id)
  end

  @spec load_game_server_pid(GameForm.t) :: {:ok, pid} | {:error, any}
  def load_game_server_pid(game_form, callback \\ &(&1)) do
    case GameServer.Registry.lookup(game_form.id) do
      [{game_server_pid, _}] ->
        {:ok, game_server_pid}
      [] ->
        state = BattleSnake.GameServerConfig.setup(game_form, callback)
        {:ok, game_server_pid} = GameServer.Registry.create(game_form.id, state)
        Process.link(game_server_pid)
        {:ok, game_server_pid}
    end
  end

  @spec handle_info(:after_join, Phoenix.Socket.t) ::
  {:noreply, Phoenix.Socket.t}
  def handle_info(:after_join,
    %{assigns: %{game_server_pid: game_server_pid}}
    = socket) do
    state = GameServer.get_state(game_server_pid)
    push(socket, "state_change", %{data: state})
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    {:noreply, socket}
  end

  def handle_info({:render, world}, socket) do
    html = Phoenix.View.render_to_string(
      BattleSnake.PlayView,
      "board.html",
      world: world)

    broadcast socket, "tick", %{html: html}

    {:noreply, socket}
  end

  def handle_in("pause", _, socket) do
    :ok = socket.assigns.game_server_pid
    |> GameServer.pause()
    {:reply, :ok, socket}
  end

  def handle_in("next", _, socket) do
    socket.assigns.game_server_pid
    |> GameServer.next()
    {:reply, :ok, socket}
  end

  def handle_in("stop", _, socket) do
    game_server_pid = socket.assigns.game_server_pid
    :ok = GenServer.stop(game_server_pid, :normal)
    {:reply, :ok, socket}
  end

  def handle_in("prev", _, socket) do
    socket.assigns.game_server_pid
    |> GameServer.prev()
    {:reply, :ok, socket}
  end

  # def handle_info({:render, state}, socket) do
  #   %{world: world} = state

  #   html = Phoenix.View.render_to_string(
  #     BattleSnake.PlayView,
  #     "board.html",
  #     world: world)

  #   broadcast socket, "tick", %{html: html}

  #   {:noreply, socket}
  # end


  # def whereis(socket) do
  #   socket
  #   |> name()
  #   |> GenServer.whereis()
  # end

  # # get the game by name if it's already running, or start a new game
  # def game_server(socket) do
  #   name(socket) |> game_server(socket)
  # end

  # def game_server(name, socket) do
  #   GenServer.whereis(name) |> game_server(name, socket)
  # end

  # # start a new game and return the pid
  # def game_server(nil, name, socket) do
  #   state = new_game_state(socket)
  #   {:ok, pid} = GameServer.start_link(state, name: {:via, Registry, {BattleSnake.GameServer.Registry, name}})
  #   pid
  # end

  # # return the already running game
  # def game_server(pid, _, _) when is_pid(pid) do
  #   pid
  # end

  # def new_game_state(socket) do
  #   socket
  #   |> game_id()
  #   |> GameForm.get()
  #   |> BattleSnake.GameServerConfig.setup(on_change(socket))
  # end

  # # game name
  # def name(socket) do
  #   {:global, socket.topic}
  # end

  # defp on_change(socket) do
  #   fn (%{world: world}) ->
  #     html = Phoenix.View.render_to_string(
  #       BattleSnake.PlayView,
  #       "board.html",
  #       world: world,
  #     )
  #     broadcast socket, "tick", %{html: html}
  #   end
  # end

  # def broadcast_tick(socket, %{world: world}) do
  #   html = Phoenix.View.render_to_string(
  #     BattleSnake.PlayView,
  #     "board.html",
  #     world: world)

  #   broadcast socket, "tick", %{html: html}
  # end
  # def broadcast_render(state, pid \\ self()) do
  #   send(pid, {:render, state})
  # end

  defp game_id(%{topic: "game:" <> id}),
    do: id

  defp authorized?(_payload) do
    true
  end
end
