defmodule BsWeb.ChannelCase do
  @moduledoc """
  This module defines the test case to be used by
  channel tests.

  Such tests rely on `Phoenix.ChannelTest` and also
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
      alias Bs.Game
      alias Bs.GameForm
      alias Bs.Point
      alias Bs.Snake
      alias Bs.SnakeForm
      alias Bs.World
      alias HTTPoison.Error
      alias HTTPoison.Response

      import Bs.Factory
      import Mox
      import Poison, only: [encode!: 1]

      use Phoenix.ChannelTest

      setup [:verify_on_exit!, :set_mox_from_context]

      # The default endpoint for testing
      @endpoint BsWeb.Endpoint
    end
  end

  setup _tags do
    on_exit(fn -> MnesiaTesting.teardown() end)

    :ok
  end
end
