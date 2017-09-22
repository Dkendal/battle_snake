defmodule Bs.GameResultSnake do
  alias __MODULE__
  require Record

  @enforce_keys [:id]

  @encoded_fields [
    :created_at,
    :game_id,
    :snake_name,
    :snake_url
  ]

  @derive {Poison.Encoder, only: @encoded_fields}

  @attributes [
    id: nil,
    created_at: nil,
    game_id: nil,
    snake_id: nil,
    snake_name: nil,
    snake_url: nil,
  ]

  defstruct @attributes
  Record.defrecord(:game_result_snake, GameResultSnake, @attributes)

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
