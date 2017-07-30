import BattleSnake.GameResultSnake, only: :macros

{:atomic, :ok} = BattleSnakeWeb.GameForm.create_table(ram_copies: [node()])
{:atomic, :ok} = BattleSnake.World.create_table(ram_copies: [node()])
{:atomic, :ok} = :mnesia.add_table_index(BattleSnake.World, :game_form_id)
{:atomic, :ok} = :mnesia.create_table(
  elem(game_result_snake(), 0), [
    attributes: Keyword.keys(game_result_snake(game_result_snake())),
    index: [:game_id]])

{:atomic, :ok} = :mnesia.create_table(
  BattleSnake.Replay,
  [attributes: BattleSnake.Replay.attributes()])

{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start
ExUnit.plural_rule("property", "properties")
