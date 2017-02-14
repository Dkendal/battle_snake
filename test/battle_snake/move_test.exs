defmodule BattleSnake.MoveTest  do
  use BattleSnake.Case, async: true
  alias BattleSnake.{
    Snake,
    Move,
    World,
    Point,
    Api.Response,
  }

  @green_snake %Snake{name: :green}

  @world %World{
    snakes: [@green_snake]
  }

  @up %Move{move: "up"}

  def up_fun(%Snake{}, %World{}) do
    %Response{parsed_response: {:ok, @up}}
  end

  def sleep_fun(%Snake{}, %World{}) do
    Process.sleep 100
    %Response{parsed_response: {:ok, @up}}
  end

  def error_fun(%Snake{}, %World{}) do
    %Response{}
  end

  describe "BattleSnake.Move.all/1" do
    test "returns a default move when the request encounters an error" do
      moves = Move.all(@world, &error_fun/2, 100)
      assert [%Move{} = move] = moves
      assert move.move == "up"
      assert {:ok, %Response{}} = move.__meta__.response
    end

    test "returns a default move when the request times-out" do
      moves = Move.all(@world, &sleep_fun/2, 0)
      assert [%Move{} = move] = moves
      assert move.move == "up"
      assert {:error, :timeout} = move.__meta__.response
    end

    test "returns a move for each snake" do
      moves = Move.all(@world, &up_fun/2, 100)
      assert [%Move{} = move] = moves
      assert move.move == "up"
      assert {:ok, %Response{}} = move.__meta__.response
    end
  end

  describe "Move.direction_to_point/1" do
    test "converts direction strings to Points" do
      assert %Point{x: 0, y: -1} ==
        %Move{move: "up"}.move |> Move.direction_to_point
    end
  end
end
