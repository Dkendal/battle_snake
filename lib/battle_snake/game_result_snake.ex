defmodule BattleSnake.GameResultSnake do
  alias __MODULE__
  require Record

  Record.defrecord(:game_result_snake, GameResultSnake,
    id: nil,
    created_at: nil,
    game_id: nil,
    snake_id: nil,
    snake_name: nil,
    snake_url: nil,
  )

  ####################
  # Type Definitions #
  ####################

  @type uuid :: binary

  @type t :: record(
    :game_result_snake,
    id: uuid,
    created_at: DateTime.t,
    game_id: uuid,
    snake_id: uuid,
    snake_name: binary,
    snake_url: binary
  )
end
