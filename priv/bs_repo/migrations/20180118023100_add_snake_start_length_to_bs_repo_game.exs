defmodule BsRepo.Migrations.AddSnakeStartLengthToBsRepoGame do
  use Ecto.Migration

  def change do
    alter table(:bs_repo_game) do
      add :snake_start_length, :any
    end
  end
end
