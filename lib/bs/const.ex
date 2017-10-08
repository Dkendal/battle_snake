defmodule Bs.Const do
  import Path

  defmacrop snake(name) do
    values =
      ["assets", "static", "images", "snake", name, "*.svg"]
      |> join
      |> wildcard
      |> Enum.map(&basename(&1, ".svg"))

    quote do
      unquote(values)
    end
  end

  def heads, do: snake("head")
  def tails, do: snake("tail")
end
