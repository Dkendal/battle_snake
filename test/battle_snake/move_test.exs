defmodule BattleSnake.MoveTest  do
  use ExUnit.Case, async: true
  alias BattleSnake.{
    Snake,
    Move,
    World,
    Api.Response}

  @green_snake %Snake{name: :green}

  @world %World{
    snakes: [@green_snake]
  }

  @left %Move{move: "left"}

  def up_fn(%Snake{}, %World{}) do
    %Response{
      parsed_response: {
        :ok,
        @left}}
  end

  def sleep_fun(%Snake{}, %World{}) do
    Process.sleep 100
    %Response{
      parsed_response: {
        :ok,
        @left}}
  end

  def error_fun(%Snake{}, %World{}) do
    %Response{}
  end

  describe "BattleSnake.Move.all/1" do
    test "returns a default move when the request encounters an error" do
      moves = Move.all(@world, &error_fun/2)
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
      moves = Move.all(@world)
      assert [%Move{} = move] = moves
      assert move.move == "up"
      assert {:ok, %Response{}} = move.__meta__.response
    end
  end
end
