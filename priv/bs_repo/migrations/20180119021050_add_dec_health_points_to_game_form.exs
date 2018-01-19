defmodule BsRepo.Migrations.AddDecHealthPointsToGameForm do
  use Ecto.Migration

  def change do
    alter table(BsRepo.GameForm) do
      add :dec_health_points, :any
    end
  end
end
