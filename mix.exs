defmodule Bs.Mixfile do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [
      app: :bs,
      version: @version,
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: preferred_cli_env(),
      test_coverage: [tool: ExCoveralls],
      erlc_options: erlc_options(Mix.env()),
      dialyzer: dialyzer(),
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Bs, []},
      extra_applications: extra_applications(Mix.env())
    ]
  end

  def erlc_options(_all) do
    [:debug_info]
  end

  def extra_applications(:dev) do
    [:mix | extra_applications(:all)]
  end

  def extra_applications(_all) do
    [:logger, :ecto_mnesia]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def preferred_cli_env do
    [
      vcr: :test,
      "vcr.delete": :test,
      "vcr.check": :test,
      "vcr.show": :test,
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test
    ]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:apex, "~> 0.7"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.8", only: [:dev, :text], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:distillery, "~> 1.1"},
      {:ecto, "~> 2.1"},
      {:ecto_mnesia, "~> 0.9.0"},
      {:edeliver, "~> 1.4"},
      {:ex_machina, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.6", only: :test},
      {:exvcr, "~> 0.8", only: :test, runtime: false},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 0.11"},
      {:meck, "~> 0.8.8", only: :test},
      {:phoenix, "~> 1.3"},
      {:phoenix_ecto, "~> 3.0"},
      {:phoenix_html, "~> 2.9"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:phoenix_pubsub, "~> 1.0"},
      {:poison, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:proper, github: "manopapad/proper", tag: "v1.2", only: :test},
      {:reprise, "~> 0.5.0", only: :dev}
    ]
  end

  defp dialyzer do
    [plt_add_deps: :transitive, plt_add_apps: [:mnesia]]
  end

  defp aliases do
    exclusions =
      [
        "lib/bs.ex",
        "lib/bs_web.ex",
        "lib/bs_web/gettext.ex",
        "lib/bs_web/router.ex",
        "lib/bs_web/views/error_helpers.ex",
      ]
      |> Enum.map(&("--exclude " <> &1))
      |> Enum.join(" ")

    [
      "bs.watch": &watch/1,
      "bs.xref": [
        "xref graph --format dot #{exclusions}",
        &xref/1
      ]
    ]
  end

  def test _ do
    Mix.shell().cmd("MIX_ENV=test mix test")
  end

  def xref(_) do
    Mix.shell().cmd("dot xref_graph.dot -Tsvg -o xref_graph.svg")
  end

  def watch(_) do
    Mix.shell().cmd(
      "watchman-make -p 'lib/**/*.ex' 'test/**/*.ex' 'test/**/*.exs' --run 'mix test --stale'"
    )
  end
end
