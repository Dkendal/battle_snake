defmodule BsWeb.SnakeForm do
  @derive {Poison.Encoder, only: [:url]}

  use BsWeb, :model

  @type t :: %__MODULE__{
    url: String.t,
    delete: boolean,
  }

  schema "snake" do
    field :url
    field :delete, :boolean, virtual: true
  end

  def changeset(snake, params \\ %{}) do
    snake
    |> cast(params, [:url, :delete])
  end
end
