defmodule Bs.Test.Agent do
  alias Bs.Test.Vector
  alias Bs.Snake

  use Ecto.Schema

  embedded_schema do
    embeds_many(:body, Vector)
  end

  defmacro agent(ast) do
    body =
      Macro.postwalk(ast, fn
        {:*, _, [x, y]} ->
          quote bind_quoted: [x: x, y: y], do: List.duplicate(x, y)

        [x, y] when is_number(x) and is_number(y) ->
          quote bind_quoted: [x: x, y: y], do: %Bs.Test.Vector{x: x, y: y}

        x ->
          x
      end)

    quote do
      %Bs.Test.Agent{
        body: List.flatten(unquote(body))
      }
    end
  end

  def to_snake(agent) do
    coords = for x <- agent.body, do: Vector.to_point(x)

    %Snake{
      id: agent.id,
      coords: coords
    }
    |> Bs.Snake.alive!()
  end
end
