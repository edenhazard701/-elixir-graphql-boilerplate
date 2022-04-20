defmodule Sntx.MixProject do
  use Mix.Project

  def project do
    [
      app: :sntx,
      version: "1.0.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      elixirc_options: [debug_info: Mix.env() == :dev],
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Sntx.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon, :bamboo_smtp]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/factories"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.4"},
      {:phoenix_ecto, "~> 4.4"},
      {:gettext, "~> 0.18"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:cors_plug, "~> 2.0"},
      {:hackney, "~> 1.8"},

      # Database
      {:ecto_sql, "~> 3.7"},
      {:ecto_enum, "~> 1.4"},
      {:ecto_psql_extras, ">= 0.0.0"},
      {:postgrex, ">= 0.0.0"},

      # Auth
      {:argon2_elixir, "~> 2.4.0"},
      {:guardian, "~> 2.2"},
      {:guardian_db, "~> 2.1"},

      # Graph
      {:absinthe, "~> 1.6.7"},
      {:absinthe_phoenix, "~> 2.0"},
      {:absinthe_plug, "~> 1.5"},
      {:dataloader, "~> 1.0"},
      {:absinthe_error_payload, "~> 1.1"},

      # Dashboard
      {:phoenix_live_dashboard, "~> 0.6"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:telemetry, "~> 0.4"},

      # Deployment
      {:edeliver, "~> 1.8"},
      {:distillery, "~> 2.1"},

      # Libs
      {:bamboo, "~> 2.2"},
      {:bamboo_smtp, "~> 4.1"},
      {:file_info, ">= 0.0.0"},
      {:nimble_csv, "~> 1.1"},
      {:paginator, "~> 1.0"},
      {:recase, "~> 0.7"},
      {:secure_random, "~> 0.5"},
      {:sentry, "~> 8.0"},
      {:timex, "~> 3.7"},
      {:waffle, "~> 1.1"},
      {:waffle_ecto, ">= 0.0.0"},

      # Dev
      {:sobelow, "~> 0.11", only: :dev},
      {:ex_machina, "~> 2.7"},
      {:faker, "~> 0.16", only: :test},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:phoenix_live_reload, "~> 1.3", only: :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": [
        "ecto.create",
        "ecto.load --skip-if-loaded",
        "ecto.migrate",
        "run priv/repo/seeds.exs"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "ecto.seed": ["run priv/repo/seeds.exs"],
      "ecto.populate": ["run priv/repo/populate.exs"],
      "ecto.migrate": ["ecto.migrate", "ecto.dump"],
      "ecto.rollback": ["ecto.rollback", "ecto.dump"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
