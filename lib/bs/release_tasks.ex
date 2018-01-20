defmodule Bs.ReleaseTasks do
  require Logger
  @app :bs
  @repos Application.get_env(@app, :ecto_repos, [])

  def storage_up do
    boot()
    print_header("Storage Up Task")

    Logger.info("Creating schema on #{node()}")

    :mnesia.change_table_copy_type(
      :schema,
      node(),
      config()[:storage_type]
    )

    case :mnesia.create_schema([node()]) do
      :ok ->
        Logger.info("Created schema")
        :ok

      {:error, {_, {:already_exists, _}}} ->
        Logger.info("Schema already exists")
        :ok
    end

    Logger.info("Done")
  end

  def migrate do
    boot()
    print_header("Migrate Task...")
    Logger.info("Booting dependencies...")
    Application.ensure_all_started(:mnesia)
    Application.ensure_all_started(:ecto)
    Application.ensure_all_started(:ecto_mnesia)
    Logger.info("[ecto_mnesia] config: #{inspect(config())}")
    Logger.info("Running migrations for #{inspect(@repos)}")
    Logger.info("Starting repos..")
    Enum.each(@repos, & &1.start_link(pool_size: 1))
    Enum.each(@repos, &run_migrations_for/1)
    Logger.info("Done")
  end

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    Logger.info("Running migrations for #{app}")
    path = migrations_path(repo)
    Logger.info("Migrations path: #{path}")
    Logger.info("Repo config: #{inspect(EctoMnesia.Storage.conf(repo.config))}")
    Ecto.Migrator.run(repo, path, :up, all: true)
  end

  defp print_header(text) do
    Logger.info("=====================================================")
    Logger.info(text)
    Logger.info("-----------------------------------------------------")
  end

  defp migrations_path(repo), do: priv_path_for(repo, "migrations")

  defp priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)

    repo_underscore =
      repo |> Module.split() |> List.last() |> Macro.underscore()

    Path.join([priv_dir(app), repo_underscore, filename])
  end

  defp config do
    :ecto_mnesia |> Application.get_all_env() |> EctoMnesia.Storage.conf()
  end

  defp boot() do
    Application.load(@app)
    Application.ensure_all_started(:logger)
    Logger.info("Loaded [#{@app}] app")
    Logger.info("Started [logger] app")
    Logger.info("Running on node [#{node()}]")
  end
end
