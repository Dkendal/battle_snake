defmodule Mix.Tasks.BattleSnake.Schema do
  use Mix.Task

  @shortdoc "creates the mnesia database"
  def run(_) do
    Application.ensure_all_started(:mnesia)
    :mnesia.change_table_copy_type(:schema, node(), :disc_copies)
    BattleSnake.GameForm.create_table(disc_copies: [node()])
    BattleSnake.World.create_table(disc_copies: [node()])
    :mnesia.add_table_index(BattleSnake.World, :game_form_id)
  end
end
