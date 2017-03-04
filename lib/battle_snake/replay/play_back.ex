defmodule BattleSnake.Replay.PlayBack do
  use GenServer
  alias BattleSnake.GameServer.PubSub
  alias BattleSnake.Replay
  require BattleSnake.Replay
  require Record

  @enforce_keys [:size, :buffer]

  defstruct([
    :buffer,
    :size,
    :replay_speed,
    :topic,
    pos: 0,
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
    frames = recorder.frames
    topic = "replay:#{game_id}"
    replay_speed = 20
    init(topic, frames, replay_speed)
  end

  def init(topic, frames, replay_speed) do
    buffer = frames
    |> :array.from_list
    |> :array.fix

    new_state = struct(__MODULE__,
      topic: topic,
      replay_speed: replay_speed,
      size: :array.size(buffer),
      buffer: buffer
    )

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

  ########
  # Seek #
  ########

  def handle_cast({:seek, :start}, state) do
    state = put_in(state.pos, 0)
    broadcast_current_frame(state)
    {:noreply, state}
  end

  def handle_cast({:seek, :end}, state) do
    pos = state.size - 1
    state = put_in(state.pos, pos)
    broadcast_current_frame(state)
    {:noreply, state}
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

  defp broadcast_prev_frame(%{pos: pos} = state)
  when pos <= 0 do
    state
  end

  defp broadcast_prev_frame(state) do
    time = state.replay_speed
    new_state = update_in(state.pos, & &1 - 1)
    broadcast_current_frame(new_state)

    Process.send_after(self(), {:broadcast_prev_frame, :auto}, time)

    new_state
  end

  defp broadcast_next_frame(%{pos: pos, size: size} = state)
  when pos >= (size - 1) do
    state
  end

  defp broadcast_next_frame(state) do
    time = state.replay_speed
    new_state = update_in(state.pos, & &1 + 1)
    broadcast_current_frame(new_state)

    Process.send_after(self(), {:broadcast_next_frame, :auto}, time)

    new_state
  end

  defp broadcast_current_frame(state) do
    topic = state.topic
    frame = :array.get(state.pos, state.buffer)
    PubSub.broadcast(topic, %Frame{data: frame})
  end
end
