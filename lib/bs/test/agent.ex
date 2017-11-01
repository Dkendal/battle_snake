defmodule Bs.Test.Agent do
  alias Bs.Test.Vector
  alias Bs.Snake

  use Ecto.Schema

  embedded_schema do
    embeds_many(:body, Vector)
  end

  def to_snake(agent) do
    coords = for x <- agent.body, do: Vector.to_point(x)

    %Snake{
      id: agent.id,
      coords: coords
    }
  end
end
