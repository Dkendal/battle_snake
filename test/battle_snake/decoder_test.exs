defmodule BattleSnake.DecoderTest do
  alias BattleSnake.Decoder
  use BattleSnake.Case, async: true

  describe "Decoder.decode" do
    defmodule Dummy do
      defstruct [:x, :y]
    end

    defmodule DummyDecoder do
      @behaviour BattleSnake.Decoder
      defstruct [:x]
      def target_struct, do: Dummy
    end

    setup do
      struct = "{\"x\":1,\"y\":2}"
      |> Decoder.decode(with: DummyDecoder)

      [struct: struct]
    end

    test "returns a struct with the whitelisted attributes", %{struct: struct} do
      assert {:ok, %Dummy{x: 1, y: nil}} == struct
    end
  end
end
