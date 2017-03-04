defmodule BattleSnake.Replay do
  alias __MODULE__
  alias BattleSnake.Replay.Recorder
  alias BattleSnake.Replay.PlayBack

  require Mnesia.Row

  Mnesia.Row.defrow(
    [:id, :attributes],
    [:id, :attributes])

  @moduledoc """
  Top level API for Replays.
  """

  defdelegate recorder_name(game_id), to: Replay.Registry
  defdelegate play_back_name(game_id), to: Replay.Registry

  def topic(game_id) do
    "replay:#{game_id}"
  end

  #################
  # Recording Api #
  #################

  def start_recording(game_id) do
    name = recorder_name(game_id)

    case Recorder.Supervisor.start_child([game_id, [name: name]]) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end

  #################
  # Play Back Api #
  #################

  def start_play_back(game_id) do
    name = play_back_name(game_id)

    case PlayBack.Supervisor.start_child([game_id, [name: name]]) do
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:ok, pid} -> {:ok, pid}
    end
  end

  def play_back_resume(game_id) do
    play_back_name(game_id)
    |> GenServer.cast(:resume)
  end

  def play_back_stop(game_id) do
    play_back_name(game_id)
    |> GenServer.cast(:stop)
  end

  def play_back_prev(game_id) do
    play_back_name(game_id)
    |> GenServer.cast(:prev)
  end

  def play_back_next(game_id) do
    play_back_name(game_id)
    |> GenServer.cast(:next)
  end

  def play_back_pause(game_id) do
    play_back_name(game_id)
    |> GenServer.cast(:pause)
  end

  def play_back_rewind(game_id) do
    play_back_name(game_id)
    |> GenServer.cast(:rewind)
  end
end
