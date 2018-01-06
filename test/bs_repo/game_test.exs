defmodule Bs.Repo.GameTest do
  alias BsRepo.Game
  use Bs.DataCase, async: false

  setup do
    {:atomic, :ok} = :mnesia.clear_table(:bs_repo_game)
    {:atomic, :ok} = :mnesia.clear_table(:id_seq)
    :ok
  end

  describe "changeset" do
    test "valid changeset" do
      params = %{
        delay: 1,
        game_mode: "singleplayer",
        height: 2,
        max_food: 3,
        recv_timeout: 4,
        width: 5,
        snakes: ["https://example.com"]
      }

      changeset = Game.changeset(%Game{}, params)

      assert changeset.valid?, inspect(changeset.errors)
    end

    test "invalid changeset" do
      params = %{
        delay: "sup",
        game_mode: "sup",
        height: -1,
        max_food: -1,
        recv_timeout: -1,
        width: -1
      }

      changeset = Game.changeset(%Game{}, params)

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
    end
  end
end
