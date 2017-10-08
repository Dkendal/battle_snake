defmodule PoisonTesting do
  @doc """
  Convert a struct to JSON and then back to a map.
  """
  @spec cast!(struct) :: map
  def cast!(s) do
    s
    |> Poison.encode!()
    |> Poison.decode!()
  end
end
