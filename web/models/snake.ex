defmodule BattleSnakeServer.Snake do
  use BattleSnakeServer.Web, :model

  schema "snake" do
    field :url
    field :delete, :boolean, virtual: true
  end

  def changeset(snake, params \\ %{}) do
    snake
    |> cast(params, [:url, :delete])
  end
end
