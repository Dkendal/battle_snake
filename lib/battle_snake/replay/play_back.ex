defmodule BattleSnake.Replay.PlayBack do
  use GenServer
  alias BattleSnake.GameServer.PubSub
  alias BattleSnake.Replay
  require BattleSnake.Replay
  require Record

  defstruct([
    :frame_buffer,
    :watched_frame_buffer,
    :receiver,
    :replay_speed,
    :topic,
    state: :suspend
  ])

  defmodule Frame, do: defstruct([:data])

  ##############
  # Start Link #
  ##############

  def start_link(args, opts) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  ########
  # Init #
  ########

  def init(game_id)
  when is_binary(game_id) do
    case Mnesia.dirty_read(Replay, game_id) do
      [] -> :ignore
      [row] -> init(row, game_id)
    end
  end

  def init(Replay.row() = row, game_id)
  when is_binary(game_id) do
    attributes = Replay.row(row, :attributes)
    bin = Keyword.fetch!(attributes, :bin)
    recorder = :erlang.binary_to_term(bin)
    frame_buffer = recorder.frames
    topic = "replay:#{game_id}"
    replay_speed = 50
    init(topic, frame_buffer, self(), replay_speed)
  end

  def init(topic, frame_buffer, receiver, replay_speed) do
    new_state = struct(__MODULE__,
      topic: topic,
      replay_speed: replay_speed,
      receiver: receiver,
      watched_frame_buffer: [],
      frame_buffer: frame_buffer)

    Dbg.trace self(), [:r]
    {:ok, new_state}
  end

  #########################
  # Handle Call Callbacks #
  #########################

  def handle_cast(:resume, state) do
    case state.state do
      s when s != :cont  ->
      (
        send(self(), {:broadcast_next_frame, :cont})
        state = put_in(state.state, :cont)
        {:noreply, state}
      )
      _ ->
      (
        {:noreply, state}
      )
    end
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_cast(:prev, state) do
    case state.state do
      _ ->
      (
        send(self(), {:broadcast_prev_frame, :cont})
        state = put_in(state.state, :suspend)
        {:noreply, state}
      )
    end
  end

  def handle_cast(:next, state) do
    case state.state do
      _ ->
      (
        send(self(), {:broadcast_next_frame, :cont})
        state = put_in(state.state, :suspend)
        {:noreply, state}
      )
    end
  end

  def handle_cast(:pause, state) do
    case state.state do
      s when s != :suspend ->
      (
        state = put_in(state.state, :suspend)
        {:noreply, state}
      )
      _ ->
      (
        {:noreply, state}
      )
    end
  end

  def handle_cast(:rewind, state) do
    case state.state do
      s when s != :rewind ->
      (
        send(self(), {:broadcast_prev_frame, :cont})
        state = put_in(state.state, :rewind)
        {:noreply, state}
      )
      _ ->
      (
        {:noreply, state}
      )
    end
  end

  #########################
  # Handle Info Callbacks #
  #########################

  def handle_info({:broadcast_next_frame, _}, %{frame_buffer: []} = state) do
    {:noreply, state, :hibernate}
  end

  def handle_info({:broadcast_next_frame, :auto}, state) do
    case state.state do
      :cont ->
        {:noreply, broadcast_next_frame(state)}
      _ ->
        {:noreply, state}
    end
  end

  def handle_info({:broadcast_next_frame, _}, state) do
    case state.state do
      _ ->
        {:noreply, broadcast_next_frame(state)}
    end
  end

  def handle_info({:broadcast_prev_frame, :auto}, state) do
    case state.state do
      :rewind ->
        {:noreply, broadcast_prev_frame(state)}
      _ ->
        {:noreply, state}
    end
  end

  def handle_info({:broadcast_prev_frame, _}, state) do
    case state.state do
      _ ->
        {:noreply, broadcast_prev_frame(state)}
    end
  end


  defp broadcast_prev_frame(%{watched_frame_buffer: []} = state) do
    state
  end

  defp broadcast_prev_frame(state) do
    time = state.replay_speed
    topic = state.topic

    {frame, new_state} =
      get_and_update_in(state.watched_frame_buffer, fn [frame | buffer] ->
        {frame, buffer}
      end)

    new_state =
      update_in(new_state.frame_buffer, fn buffer ->
        [frame | buffer]
      end)

    Process.send_after(self(), {:broadcast_prev_frame, :auto}, time)
    PubSub.broadcast(topic, %Frame{data: frame})

    new_state
  end

  defp broadcast_next_frame(%{frame_buffer: []} = state) do
    state
  end

  defp broadcast_next_frame(state) do
    time = state.replay_speed
    topic = state.topic

    {frame, new_state} =
      get_and_update_in(state.frame_buffer, fn [frame | buffer] ->
        {frame, buffer}
      end)

    new_state =
      update_in(new_state.watched_frame_buffer, fn buffer ->
        [frame | buffer]
      end)

    Process.send_after(self(), {:broadcast_next_frame, :auto}, time)
    PubSub.broadcast(topic, %Frame{data: frame})

    new_state
  end
end
