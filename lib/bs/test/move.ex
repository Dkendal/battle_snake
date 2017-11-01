defmodule Bs.Test.Move do
  use Ecto.Schema

  embedded_schema do
    field(:move, :string)
  end
end
