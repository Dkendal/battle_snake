{:ok, _} = Application.ensure_all_started(:ex_machina)

ExUnit.start(
  exclude: [:skip, :pending],
  include: :focus,
  capture_log: true,
  case_load_timeout: 5000
)

ExUnit.plural_rule("property", "properties")
