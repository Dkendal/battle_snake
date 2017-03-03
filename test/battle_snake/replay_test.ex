defmodule BattleSnake.ReplayTest do
  alias BattleSnake.Replay
  use BattleSnake.Case, async: true

  describe "Replay.start_recording(topic)" do
    test "starts a recorder" do
      topic = "topic-1"
      {:ok, pid} = Replay.start_recording(topic)
      assert is_pid pid
    end

    test "erases any existings recording"
  end

  describe "Replay.stop_recording(topic)" do
    test "stops recording" do
      topic = "topic-1"
      {:ok, pid} = Replay.stop_recording(topic)
    end

    test "hibernates the recorder"
  end

  describe "Replay.stop(topic)" do
    test "stops the recorder" do
      topic = "topic-1"
      :ok = Replay.stop(topic)
    end

    test "stops any playbacks" do
      topic = "topic-1"
      :ok = Replay.stop(topic)
    end
  end

  describe "Replay.load_recording(topic)" do
    test "starts a play back server" do
      # Replay.load_recording()
    end
  end

  describe "Replay.play_recording(topic)" do
    test "starts broadcasting to the caller" do
    end
  end
end

defmodule BattleSnake.Replay.PlayBackTest do
  alias BattleSnake.Replay.PlayBack
  use BattleSnake.Case, async: true

  ########
  # Play #
  ########

  describe "ReplayPlayBack.handle_cast(:play, state)" do
    test "sends a :broadcast message to the caller" do
      {:ok, state} = PlayBack.init("game-1", [1], self(), 0)
      {:noreply, ^state} = PlayBack.handle_cast(:play, state)
    end
  end

  #############
  # Broadcast #
  #############

  describe "ReplayPlayBack.handle_info(:broadcast, state)" do
    test "broadcasts the frame to the receiver" do
      {:ok, state} = PlayBack.init("game-1", [1], self(), 0)

      {:noreply, state} = PlayBack.handle_info(:broadcast, state)

      assert_receive %PlayBack.Frame{data: 1}

      {:stop, :normal, _state} = PlayBack.handle_info(:broadcast, state)
    end

    test "sends a :broadcast message to the caller" do
      {:ok, state} = PlayBack.init("game-1", [1], self(), 0)

      {:noreply, state} = PlayBack.handle_info(:broadcast, state)
      assert_receive :broadcast

      {:stop, :normal, _state} = PlayBack.handle_info(:broadcast, state)
      refute_receive :broadcast
    end
  end
end
