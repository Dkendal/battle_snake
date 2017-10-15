defmodule Bs.Case do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build and query models.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Bs.Factory
      import :meck
      import Poison, only: [encode!: 1]
      defdelegate(mock(mod), as: :new, to: :meck)
      defdelegate(mock(mod, opts), as: :new, to: :meck)

      def named_mock_game_server(id) do
        {:ok, pid} =
          Agent.start_link(fn -> 0 end, name: {
            :via,
            Registry,
            {Bs.Game.Registry, id}
          })

        pid
      end
    end
  end

  setup _tags do
    on_exit(fn ->
      Bs.GameServerTesting.teardown()
      MnesiaTesting.teardown()
    end)

    :ok
  end
end
