use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config(:bs, BsWeb.Endpoint, http: [port: 4001], server: false)

config(:bs, :http, Bs.HTTPMock)
config(:bs, :db, Bs.RepoMock)
config(:bs, :api, Bs.ApiMock)

# Print only warnings and errors during test
config(:logger, level: :debug)
