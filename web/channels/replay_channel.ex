defmodule BattleSnake.ReplayChannel do
  use BattleSnake.Web, :channel
  alias BattleSnake.Replay
  alias BattleSnake.Replay.PlayBack
  alias BattleSnake.Replay.PlayBack.Frame
  alias BattleSnake.GameServer.PubSub

  #################
  # Join Callback #
  #################

  def join("replay:html:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  def join("replay:json:" <> game_id, payload, socket) do
    do_join(game_id, payload, socket)
  end

  defp do_join(game_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :game_id, game_id)
      send(self(), :after_join)

      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  #########################
  # Handle Info Callbacks #
  #########################

  ##############
  # After Join #
  ##############

  def handle_info(:after_join, socket) do
    game_id = socket.assigns.game_id
    {:ok, _pid} = Replay.start_play_back(game_id)
    topic = Replay.topic(game_id)
    :ok = PubSub.subscribe(topic)
    {:noreply, socket}
  end

  ###################
  # Replay Controls #
  ###################

  def handle_in("resume", _from, socket) do
    Replay.play_back_resume(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_in("stop", _from, socket) do
    Replay.play_back_stop(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_in("prev", _from, socket) do
    Replay.play_back_prev(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_in("next", _from, socket) do
    Replay.play_back_next(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_in("pause", _from, socket) do
    Replay.play_back_pause(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_in("rewind", _from, socket) do
    Replay.play_back_rewind(socket.assigns.game_id)
    {:noreply, socket}
  end

  def handle_in("seek:start", _from, socket) do
    Replay.play_back_seek(
      socket.assigns.game_id,
      :start)
    {:noreply, socket}
  end

  def handle_in("seek:end", _from, socket) do
    Replay.play_back_seek(
      socket.assigns.game_id,
      :end)
    {:noreply, socket}
  end

  ###########################
  # Process Frame Broadcast #
  ###########################

  def handle_info(%Frame{data: state}, socket) do
    content = render_content(content_type(socket), state)
    broadcast(socket, "tick", %{content: content})
    {:noreply, socket}
  end

  ###################
  # Private Methods #
  ###################

  defp authorized?(_payload) do
    true
  end

  defp render_content("json", state) do
    Poison.encode!(state.world, mode: :consumer)
  end

  defp render_content(_, state) do
    BattleSnake.SpectatorView
    |> Phoenix.View.render_to_string("board.html", state: state)
    |> String.replace(~r/^\s+|\s+$/m, "")
    |> String.replace(~r/\n+/m, " ")
  end

  defp content_type(socket) do
    [_, type|_] = String.split(socket.topic, ":")
    type
  end
end
