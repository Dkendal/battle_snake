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
  def handle_in("start", _, socket) do
    game_server(socket) |> GameServer.resume()

    {:reply, :ok, socket}
  end

  def handle_in("pause", _, socket) do
    with pid when is_pid(pid) <- whereis(socket),
      GameServer.pause(pid),
      do: :ok

    {:reply, :ok, socket}
  end

  def handle_in("next", _, socket) do
    game_server(socket) |> GameServer.next()

    {:reply, :ok, socket}
  end


  def handle_in("stop", _, socket) do
    with pid when is_pid(pid) <- whereis(socket),
      GenServer.stop(pid, :normal),
      do: :ok

    {:reply, :ok, socket}
  end

  def handle_in("prev", _, socket) do
    with pid when is_pid(pid) <- whereis(socket),
      GameServer.prev(pid),
      do: :ok

    {:reply, :ok, socket}
  end

  def whereis(socket) do
    socket
    |> name()
    |> GenServer.whereis()
  end

  # get the game by name if it's already running, or start a new game
  def game_server(socket) do
    name(socket) |> game_server(socket)
  end

  def game_server(name, socket) do
    GenServer.whereis(name) |> game_server(name, socket)
  end

  # start a new game and return the pid
  def game_server(nil, name, socket) do
    state = new_game_state(socket)
    {:ok, pid} = GameServer.start_link(state, name: name)
    pid
  end

  # return the already running game
  def game_server(pid, _, _) when is_pid(pid) do
    pid
  end

  def new_game_state(socket) do
    {:ok, _} = @api.start

    "game:" <> id = socket.topic

    game = Game.get(id)

    game = Game.reset_world game

    world = game.world

    opts = [
      delay: game.delay,
      objective: &BattleSnake.WinConditions.single_player/1
    ]

    reducer = reducer(socket)
    on_change = draw(socket)

    state = %GameServer.State{
      world: world,
      reducer: reducer,
      opts: opts,
      on_change: on_change,
    }
  end

  # game name
  def name(socket) do
    {:global, socket.topic}
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

  defp draw(socket) do
    fn (%{world: world}) ->
      html = Phoenix.View.render_to_string(
        BattleSnakeServer.PlayView,
        "board.html",
        world: world,
      )
      broadcast socket, "tick", %{html: html}
    end
  end

  def reducer(socket) do
    fn world ->
      world = update_in(world.turn, &(&1+1))

      world
      |> make_move
      |> World.step
      |> World.stock_food
    end
  end


  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
