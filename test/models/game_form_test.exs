defmodule Bs.GameTest do
  alias BsWeb.GameForm
  use Bs.Case, async: true

  test "creating a new record" do
    assert {:ok, _} = BsRepo.insert %GameForm{
      world: %Bs.World{},
      snakes: [%BsWeb.SnakeForm{}]
    }
  end

  describe "Poison.Encoder.encode(%BsWeb.GameForm{}, [])" do
    @game_form %GameForm{id: 1,
                         height: 2,
                         width: 3}

    @json %{"game_id" => 1,
            "height" => 2,
            "width" => 3}

    @expected PoisonTesting.cast! @game_form

    test "returns formatted JSON" do
      assert @expected == @json
    end
  end
end
