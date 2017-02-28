defmodule BattleSnake.GameResult do
  alias __MODULE__
  require Record

  Record.defrecord(:game_result, GameResult,
    id: nil,
    snake_id: nil,
    game_id: nil,
    is_winner: nil,
    created_at: nil)

  ####################
  # Type Definitions #
  ####################

  @type uuid :: binary

  @type t :: record(
    :game_result,
    id: uuid,
    snake_id: uuid,
    game_id: uuid,
    is_winner: boolean,
    created_at: DateTime.t
  )
end
