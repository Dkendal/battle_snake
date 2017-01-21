defmodule Mix.Tasks.BattleSnake.Createdb do
  alias BattleSnake.GameForm

  use Mix.Task

  @shortdoc "creates the mnesia database"
  def run(_) do
    :stopped = :mnesia.stop
    :ok = :mnesia.delete_schema([node()])
    :ok = :mnesia.create_schema([node()])
    :ok = :mnesia.start()

    {:atomic, :ok} = :mnesia.create_table(
      GameForm,
      [{:disc_copies, [node()]} |
       GameForm.table])
  end
end
