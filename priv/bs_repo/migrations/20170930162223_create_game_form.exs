defmodule BsRepo.Migrations.CreateGameForm do
  use Ecto.Migration

  def change do
    create_if_not_exists table(BsWeb.GameForm, engine: :set) do
      add :snakes, :any
      add :world, :any
      add :width, :any
      add :height, :any
      add :delay, :any
      add :max_food, :any
      add :game_mode, :any
      add :recv_timeout, :any
    end
  end
end
