import Config

config :sntx, SntxWeb.Endpoint,
  http: [port: 4000],
  server: false

config :sntx, Sntx.Repo,
  url: System.get_env("SNTX_TEST_DB"),
  pool: Ecto.Adapters.SQL.Sandbox

# Print only warnings and errors during test
config :logger, level: :warn
