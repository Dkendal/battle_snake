defmodule BattleSnake.Mixfile do
  use Mix.Project

  def project do
    [app: :battle_snake,
     version: "1.0.0",
     elixir: "~> 1.4",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     preferred_cli_env: preferred_cli_env(),
     test_coverage: [tool: ExCoveralls],
     deps: deps()]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {BattleSnake, []},
     extra_applications: extra_applications(Mix.env)]
  end

  def extra_applications(_all) do
    [:logger,
     :mnesia]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  def preferred_cli_env do
    [
      vcr: :test,
      "vcr.delete": :test,
      "vcr.check": :test,
      "vcr.show": :test,
      "coveralls": :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:ecto, "~> 2.0"},
      {:excoveralls, "~> 0.6", only: :test},
      {:exrm, "~> 1.0.0"},
      {:exvcr, "~> 0.8", only: :test},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 0.11"},
      {:phoenix, "~> 1.2"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.6"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:poison, "~> 2.0"},
      {:proper, github: "manopapad/proper", only: :test},
      {:reprise, "~> 0.5.0", only: :dev},
    ]
  end
end
