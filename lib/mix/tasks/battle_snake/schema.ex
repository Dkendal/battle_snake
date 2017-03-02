defmodule Mix.Tasks.BattleSnake.Schema.Drop do
  use Mix.Task

  @shortdoc "delete the current schema"
  def run(_) do
    :mnesia.delete_schema([node()])
    |> inspect
    |> Mix.shell.info
  end
end

defmodule Mix.Tasks.BattleSnake.Schema.Create do
  use Mix.Task

  @shortdoc "create the mnesia schema on disk"
  def run(_) do
    Application.ensure_all_started(:mnesia)
    :mnesia.change_table_copy_type(:schema, node(), :disc_copies)
    |> inspect
    |> Mix.shell.info
  end
end

defmodule Mix.Tasks.BattleSnake.Schema.Tables.Create do
  use Mix.Task

  @shortdoc "creates the mnesia database"
  def run(_) do
    Mnesia.install([node()])
  end
end
