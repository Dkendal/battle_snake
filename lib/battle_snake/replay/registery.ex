defmodule BattleSnake.Replay.Registry do
  def recorder_name(game_id) do
    {:via, Registry, {BattleSnake.Replay.Registry, "recorder:#{game_id}"}}
  end

  def play_back_name(game_id) do
    {:via, Registry, {BattleSnake.Replay.Registry, "playback:#{game_id}"}}
  end
end
