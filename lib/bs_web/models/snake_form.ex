defmodule BsWeb.SnakeForm do
  @derive {Poison.Encoder, only: [:url]}

  use BsWeb, :model

  embedded_schema do
    field :url
    field :delete, :boolean, virtual: true
  end

  def changeset(snake, params \\ %{}) do
    snake
    |> cast(params, [:url, :delete])
  end
end
