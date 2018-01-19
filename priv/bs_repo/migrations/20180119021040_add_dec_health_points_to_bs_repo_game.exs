defmodule BsRepo.Migrations.AddDecHealthPointsToBsRepoGame do
  use Ecto.Migration

  def change do
    alter table(:bs_repo_game) do
      add :dec_health_points, :any
    end
  end
end
