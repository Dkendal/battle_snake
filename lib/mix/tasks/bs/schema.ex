defmodule Mix.Tasks.Bs.Schema.Drop do
  use Mix.Task

  @shortdoc "delete the current schema"
  def run(_) do
    Mnesia.delete_schema([node()])
    |> inspect
    |> Mix.shell.info
  end
end
