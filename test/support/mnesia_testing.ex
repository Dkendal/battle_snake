defmodule MnesiaTesting do
  def teardown do
    :mnesia.clear_table(BattleSnake.GameForm)
  end
end
