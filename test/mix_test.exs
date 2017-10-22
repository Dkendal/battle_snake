defmodule MixTest do
  use Bs.Case, async: true

  defmodule User do
    defstruct [:id, :foo, :bar]
  end

  test "#path" do
    assert(
      Mix.Tasks.Phx.Gen.View.path(["Accounts", "User", "MixTest.User"]) ==
        "lib/bs_web/views/accounts/user_view.ex"
    )
  end

  test "#gen" do
    assert(
      Mix.Tasks.Phx.Gen.View.gen(["Accounts", "User", "MixTest.User"]) ==
        String.trim(~S"""
        defmodule(BsWeb.Accounts.UserView) do
          use(BsWeb, :view)
          def(render("show.json", %{user: user})) do
            %{bar: user.bar(), foo: user.foo(), id: user.id()}
          end
        end
        """)
    )
  end
end
