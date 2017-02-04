defmodule BattleSnake.Decoder do
  @doc """
  A struct that contains all whitelisted parameters.

  Acts as an intermediate product.
  """
  @callback __struct__() :: struct

  @doc """
  What struct the final result should be.
  """
  @callback target_struct() :: struct

  @typedoc """
  A module that implements the BattleSnake.Decoder behavior.
  """
  @type decoder :: module

  @doc """
  Parse a JSON binary, using the given decoder to whitelist the attributes.
  """
  @spec decode(binary, with: decoder) :: struct
  def decode(json, with: decoder) do
    whitelist = decoder.__struct__
    target_struct = decoder.target_struct()

    with {:ok, parsed_result} <- Poison.decode(json, as: whitelist) do
      map = Map.from_struct(parsed_result)
      result = struct(target_struct, map)
      {:ok, result}
    end
  end
end
