defmodule BattleSnakeServer.GameChannel do
  @api Application.get_env(:battle_snake_server, :snake_api)

  alias BattleSnake.{Snake, World, GameServer}
  alias BattleSnakeServer.{Game}

  use BattleSnakeServer.Web, :channel

  def join("game:" <> game_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("start", payload, socket) do
    {:ok, _} = @api.start

    "game:" <> id = socket.topic

    game = Game.get(id)

    game = Game.reset_world game

    world = game.world

    draw = fn
      world ->
        html = Phoenix.View.render_to_string(
          BattleSnakeServer.PlayView,
          "board.html",
          world: world,
        )
        broadcast socket, "tick", %{html: html}
    end

    f = fn world ->
      draw.(world)

      world = update_in(world.turn, &(&1+1))

      world
      |> make_move
      |> World.step
      |> World.stock_food
    end

    opts = [
      delay: 300,
      objective: &BattleSnake.WinConditions.single_player/1
    ]

    state = {world, f, opts}

    {:ok, pid} = GameServer.start_link(state)

    GameServer.resume(pid)

    {:reply, :ok, socket}
  end

  def handle_in("pause", _, socket) do
    {:reply, :ok, socket}
  end

  def make_move world do
    moves = for snake <- world.snakes do
      move = @api.move(snake, world)
      {snake.name, move.move}
    end

    moves = Enum.into moves, %{}

    world = put_in world.moves, moves

    World.apply_moves(world, moves)
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
