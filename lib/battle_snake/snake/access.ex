defmodule BattleSnake.Snake.Access do
  @moduledoc """
  Defines how keys are generated for snakes so that they may be accessed
  throughout the world state.

  This is to avoid the issue of colliding names causing other snakes to be
  overwritten.
  """

  alias BattleSnake.Snake

  defmodule Key do
    import Base, only: [encode64: 1]
    import :crypto, only: [hash: 2]
    defstruct [:value]
    @opaque t :: %Key{}

    @spec new(Snake.t) :: t
    def new(%Snake{name: name, url: url}),
      do: new(name, url)

    defp new(name, url)
    when is_atom(name) or is_atom(url),
      do: new(to_string(name), to_string(url))

    defp new(name, url)
    when is_binary(name) and is_binary(url),
      do: %Key{value: encode64(hash(:md5, name <> url))}
  end

  @opaque key :: %Key{}

  @doc """
  Generate a key for a snake.
  """
  @spec key(Snake.t) :: key
  def key(snake), do: Key.new(snake)
end

defimpl Inspect, for: BattleSnake.Snake.Access.Key do
  import Inspect.Algebra
  def inspect(%{value: value}, _opts),
    do: concat(["#Key//", value])
end
