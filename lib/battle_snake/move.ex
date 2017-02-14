defmodule BattleSnake.Move do
  alias __MODULE__
  alias BattleSnake.{
    World,
    Point,
    Snake,
    Api.Response,
  }

  defstruct [
    :move,
    :taunt,
    :snake_id,
    __meta__: %Move.Meta{}
  ]

  @type direction :: String.t
  @type t :: %__MODULE__{
    move: direction,
    taunt: String.t,
    snake_id: reference
  }

  @api Application.get_env(:battle_snake, :snake_api)

  defmacrop default_move(), do: quote do: %Move{move: "up"}

  @doc """
  Collects all moves for all living snakes for world.

  For each snake in world.snakes, a linked task is started, which in turn
  starts an unlinked task when performs the actual request.

  When the requesting task times-out it is killed, and the default move is
  reported back to the supervising task which is then aggregated with the
  other results.
  """

  @spec all(World.t, ((Snake.t, World.t) -> Response.t)) :: [Snake.t]
  def all(world, request_fun \\ &@api.move/2, timeout \\ 200) do
    snakes = world.snakes

    do_task =
    fn (snake) ->
      {:ok, sup_pid} = Task.Supervisor.start_link()

      work_fn = fn ->
        request_fun.(snake, world)
      end

      task = Task.Supervisor.async_nolink(sup_pid, work_fn)

      move =
        case Task.yield(task, timeout) || Task.shutdown(task) do
          {:ok, %Response{parsed_response: {:ok, move}} = response} ->
            put_in move.__meta__.response, {:ok, response}
          {:ok, %Response{parsed_response: {:error, _}} = response} ->
            move = default_move()
            put_in move.__meta__.response, {:ok, response}
          nil ->
            move = default_move()
            put_in move.__meta__.response, {:error, :timeout}
        end

      # identify what snake this move belongs to.
      put_in(move.snake_id, snake.id)
    end

    # The async stream shouldn't fail to respond.
    # we're timing idividual tasks above.
    snakes
    |> Task.async_stream(do_task, timeout: :infinity)
    |> Enum.into([], fn {:ok, value} -> value end)
  end

  @spec response_timeout(Move.t) :: Move.t
  def response_timeout(move) do
    put_in move.__meta__.response_state, :timeout
  end

  @spec response_ok(Move.t) :: Move.t
  def response_ok(move) do
    put_in move.__meta__.response_state, :ok
  end

  @spec response_error(Move.t, Exception.t) :: Move.t
  def response_error(move, error) do
    put_in move.__meta__.response_state, {:error, error}
  end

  def response(move, response) do
    put_in move.__meta__.response, response
  end

  def up,     do: %Point{x: 0,  y: -1}
  def down,   do: %Point{x: 0,  y: 1}
  def right,  do: %Point{x: 1,  y: 0}
  def left,   do: %Point{x: -1, y: 0}

  def moves do
    [
      up(),
      down(),
      left(),
      right(),
    ]
  end

  def to_point(%Move{move: move}),
    do: to_point(move)

  def to_point(move) when is_binary(move) do
    case move do
      "up" -> up()
      "down" -> down()
      "left" -> left()
      "right" -> right()
    end
  end
end
