defmodule MnesiaTesting do
  def teardown do
    for table <- :mnesia.system_info(:tables) -- [:schema] do
      :mnesia.clear_table(table)
    end
  end
end
