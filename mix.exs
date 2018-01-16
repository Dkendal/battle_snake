defmodule Bs.Mixfile do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))

  def project do
    [
      aliases: aliases(),
      app: :bs,
      build_embedded: Mix.env() == :prod,
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      deps: deps(),
      dialyzer: dialyzer(),
      name: "BattleSnake",
      docs: [
        debug: true,
        main: "Bs",
        logo: "assets/static/images/division-advanced.png",
        assets: "assets/docs",
        before_closing_head_tag: &before_closing_head_tag/1,
        extras: [
          "README.md"
          | Path.wildcard("lib/bs/pages/**/*.md")
        ]
      ],
      elixir: ">= 1.5.3",
      elixirc_paths: elixirc_paths(Mix.env()),
      erlc_options: erlc_options(Mix.env()),
      homepage_url: "https://github.com/battle-snake/battle_snake",
      preferred_cli_env: preferred_cli_env(),
      source_url: "https://github.com/battle-snake/battle_snake",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  def before_closing_head_tag(:html) do
    """
    <script src="assets/node_modules/mermaid/dist/mermaid.min.js"></script>
    <script>mermaid.initialize({startOnLoad:true});</script>
    """
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
      {:apex, "~> 1.2"},
      {:cowboy, "~> 1.0"},
      {:credo, "~> 0.8", only: [:dev, :text], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:distillery, "~> 1.5", runtime: false},
      {:ecto, "~> 2.1"},
      {:ecto_mnesia, "~> 0.9.0"},
      {:edeliver, "~> 1.4"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:ex_machina, "~> 2.1", only: :test},
      {:excoveralls, "~> 0.6", only: :test},
      {:exvcr, "~> 0.8", only: :test, runtime: false},
      {:gettext, "~> 0.11"},
      {:httpoison, "~> 0.11"},
      {:meck, "~> 0.8.8", only: :test},
      {:mox, "~> 0.3", only: :test},
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
        "lib/bs_web/views/error_helpers.ex"
      ]
      |> Enum.map(&("--exclude " <> &1))
      |> Enum.join(" ")

    [
      "bs.watch": &watch/1,
      "bs.graph": [
        "xref graph --format dot #{exclusions}",
        &xref/1
      ]
    ]
  end

  def test _ do
    "MIX_ENV=test mix test"
    |> Mix.shell().cmd()
  end

  def xref(_) do
    "dot xref_graph.dot -Tsvg -o xref_graph.svg"
    |> Mix.shell().cmd()
  end

  def watch(_) do
    """
    watchman-make -p 'lib/**/*.ex' \
      'test/**/*.ex' \ 'test/**/*.exs' \
      --run 'mix test --stale --color=true'
    """
    |> Mix.shell().cmd()
  end
end
