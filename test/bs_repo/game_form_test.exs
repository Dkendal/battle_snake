defmodule BsRepo.GameFormTest do
  alias BsRepo.GameForm
  use Bs.Case, async: true

  setup do
    {:atomic, :ok} = :mnesia.clear_table(Elixir.BsRepo.GameForm)
    {:atomic, :ok} = :mnesia.clear_table(:id_seq)
    :ok
  end

  test "creating a new record" do
    assert {:ok, _} =
             BsRepo.insert(%GameForm{
               world: %Bs.World{},
               snakes: [%BsWeb.SnakeForm{}]
             })
  end

  describe "Poison.Encoder.encode(%BsRepo.GameForm{}, [])" do
    @game_form %GameForm{id: 1, height: 2, width: 3}

    @json %{"game_id" => 1, "height" => 2, "width" => 3}

    @expected PoisonTesting.cast!(@game_form)

    test "returns formatted JSON" do
      assert @expected == @json
    end
  end

  describe "changeset" do
    test "valid changeset" do
      params = %{
        delay: 1,
        game_mode: "singleplayer",
        height: 2,
        max_food: 3,
        snake_start_length: 5,
        recv_timeout: 4,
        width: 5,
        dec_health_points: 0
      }

      changeset = GameForm.changeset(%GameForm{}, params)

      assert changeset.valid?, inspect(changeset.errors)
    end

    test "invalid changeset" do
      params = %{
        delay: "sup",
        game_mode: "sup",
        height: -1,
        max_food: -1,
        snake_start_length: 0,
        recv_timeout: -1,
        width: -1,
        dec_health_points: -1
      }

      changeset = GameForm.changeset(%GameForm{}, params)

      refute changeset.valid?

      assert changeset.errors[:delay] ==
               {
                 "is invalid",
                 [type: :integer, validation: :cast]
               }

      assert changeset.errors[:game_mode] ==
               {
                 "is invalid",
                 [validation: :inclusion]
               }

      assert changeset.errors[:height] ==
               {
                 "must be greater than or equal to %{number}",
                 [validation: :number, number: 2]
               }

      assert changeset.errors[:width] ==
               {
                 "must be greater than or equal to %{number}",
                 [validation: :number, number: 2]
               }

      assert changeset.errors[:max_food] ==
               {
                 "must be greater than or equal to %{number}",
                 [validation: :number, number: 0]
               }

      assert changeset.errors[:snake_start_length] ==
               {
                 "must be greater than or equal to %{number}",
                 [validation: :number, number: 1]
               }

      assert changeset.errors[:dec_health_points] ==
               {
                 "must be greater than or equal to %{number}",
                 [validation: :number, number: 0]
               }
    end
  end
end
