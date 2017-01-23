defmodule BattleSnake.GameServer.Persistance do
  alias BattleSnake.{GameForm, GameServer}

  @doc """
  Saves the winner of the game to the state.game_form.
  """
  @spec save_winner(GameServer.state) :: GameServer.state
  def save_winner(state) do
    do_save_winner(state)
  end

  defp do_save_winner(state) do
    update_in state.game_form, fn game_form ->
      winners = winners(state)

      game_form
      |> GameForm.changeset()
      |> Ecto.Changeset.put_change(:winners, winners)
      |> Ecto.Changeset.apply_changes
      |> GameForm.save
    end
  end

  defp winners(state) do
    state.winners
  end
end
