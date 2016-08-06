use Mix.Config
config :battle_snake_server, snake_api: BattleSnakeServer.Snake.MockApi

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :battle_snake_server, BattleSnakeServer.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
