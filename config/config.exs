# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :bs, BsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    "lYYgnflsbniY0f9RgALnSmr0nGSwGWkm+rMqgDHhrywKUolAqni+7zdTKAumE5R/",
  render_errors: [view: BsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bs.PubSub, adapter: Phoenix.PubSub.PG2]

config :bs, start_timeout: 10_000

config :bs, :api, Bs.Api
config :bs, :http, HTTPoison
config :bs, :db, BsRepo

config :bs, ecto_repos: [BsRepo]

config :bs, BsRepo, adapter: EctoMnesia.Adapter

config :ecto_mnesia,
  host: {:system, :atom, "MNESIA_HOST", Kernel.node()},
  storage_type: {:system, :atom, "MNESIA_STORAGE_TYPE", :disc_copies}

config :mnesia, dir: 'priv/data/mnesia'

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
