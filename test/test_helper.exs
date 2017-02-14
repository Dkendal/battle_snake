{:atomic, :ok} = BattleSnake.GameForm.create_table(ram_copies: [node()])
{:atomic, :ok} = BattleSnake.World.create_table(ram_copies: [node()])
{:atomic, :ok} = :mnesia.add_table_index(BattleSnake.World, :game_form_id)

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start
ExUnit.plural_rule("property", "properties")
