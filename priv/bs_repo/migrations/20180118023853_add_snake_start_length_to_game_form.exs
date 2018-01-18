defmodule BsRepo.Migrations.AddSnakeStartLengthToGameForm do
  use Ecto.Migration

  def change do
    alter table(BsRepo.GameForm) do
      add :snake_start_length, :any
    end
  end
end
