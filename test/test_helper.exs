{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start(exclude: [:skip, :pending], include: :focus)

ExUnit.plural_rule("property", "properties")
