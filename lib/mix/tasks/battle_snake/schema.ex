defmodule Mix.Tasks.BattleSnake.Schema.Drop do
  use Mix.Task

  @shortdoc "delete the current schema"
  def run(_) do
    Mnesia.delete_schema([node()])
    |> inspect
    |> Mix.shell.info
  end
end

defmodule Mix.Tasks.BattleSnake.Schema.Install do
  use Mix.Task

  @shortdoc "create the mnesia schema on disk"
  def run(_) do
    Mnesia.install([node()])
  end
end
