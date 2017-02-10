use Mix.Config
config :battle_snake, snake_api: BattleSnake.MockApi

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :battle_snake, BattleSnake.Endpoint,
  http: [port: 4001],
  server: false

config(:mnesia,
  dir: './databases/test',
  debug: false)

# Print only warnings and errors during test
config :logger, level: :warn
