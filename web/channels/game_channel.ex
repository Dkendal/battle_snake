defmodule BattleSnakeServer.GameChannel do
  alias BattleSnake.{Snake, World}
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
    spawn fn ->
      snake = Snake.new(%{}, 20, 20)

      world_params = %{
        "snakes" => [snake],
        "turn" => 0,
        rows: 20,
        cols: 20,
      }

      world = World.new(world_params, width: 20, height: 20)
      |> World.init_food(4)
      |> World.update_board

      draw = fn (socket) ->
        fn (state) ->
          html = Phoenix.View.render_to_string(
            BattleSnakeServer.PlayView,
            "board.html",
            world: state,
          )
          broadcast socket, "tick", %{html: html}
        end
      end

      tick(world, world, draw.(socket))
    end

    {:reply, {:ok, payload}, socket}
  end

  def tick(%{"snakes" => []} = state, previous, draw) do
    # print previous
    # IO.puts "Game Over"
    :ok
  end

  def tick(state, previous, draw) do
    Process.sleep 50

    spawn_link fn ->
      draw.(state)
    end

    state
    |> update_in(["turn"], & &1 + 1)
    |> make_move
    |> World.step
    |> World.add_new_food
    |> World.update_board
    |> tick(state, draw)
  end

  def make_move state do
    moves = for snake <- state["snakes"] do
      name = snake["name"]
      {name, "up"}
    end

    moves = Enum.into moves, %{}

    World.apply_moves(state, moves)
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (game:lobby).
  def handle_in("tick", payload, socket) do
    broadcast socket, "tick", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
