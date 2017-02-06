defmodule BattleSnake.GameAdminChannelTest do
  use BattleSnake.ChannelCase

  alias BattleSnake.GameAdminChannel

  setup do
    game_id = 1

    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(GameAdminChannel, "game_admin:" <> game_id)

    {:ok, socket: socket}
  end
end
