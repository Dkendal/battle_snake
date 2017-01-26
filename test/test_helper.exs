:stopped = :mnesia.stop
:ok = :mnesia.delete_schema([node()])
:ok = :mnesia.create_schema([node()])
:ok = :mnesia.start()

{:atomic, :ok} = BattleSnake.GameForm.create_table(ram_copies: [node()])
{:atomic, :ok} = BattleSnake.World.create_table(ram_copies: [node()])

ExUnit.start
ExUnit.plural_rule("property", "properties")
