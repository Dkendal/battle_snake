defmodule Bs.Test.Scenario do
  alias Bs.Test.Agent
  alias Bs.Test.Vector
  alias Bs.World

  use Ecto.Schema

  embedded_schema do
    field(:width, :integer)
    field(:height, :integer)
    embeds_one(:player, Agent)
    embeds_many(:agents, Agent)
    embeds_many(:food, Vector)
  end

  def to_world(scenario) do
    food = for x <- scenario.food, do: Vector.to_point(x)

    snakes =
      for x <- [scenario.player | scenario.agents] do
        Agent.to_snake(x)
      end

    [player | _] = snakes

    world = %World{
      id: Ecto.UUID.generate(),
      game_id: :rand.uniform(999_999_999),
      snakes: snakes,
      width: scenario.width,
      height: scenario.height,
      food: food
    }

    {world, player}
  end
end
