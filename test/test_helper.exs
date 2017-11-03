{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start(exclude: [:skip, :pending], include: :focus, capture_log: true)

ExUnit.plural_rule("property", "properties")
