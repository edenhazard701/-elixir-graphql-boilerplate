import Config

config :sntx, SntxWeb.Endpoint,
  http: [port: System.get_env("SNTX_PORT")],
  url: [
    host: System.get_env("SNTX_PRODUCTION_HOST"),
    scheme: System.get_env("SNTX_PRODUCTION_HOST_SCHEMA"),
    port: System.get_env("SNTX_PRODUCTION_HOST_PORT")
  ],
  server: true,
  code_reloader: false,
  check_origin: [
    "https://sntx.pl",
    "//*.sntx.pl",
    "//localhost"
  ]

config :sntx, Sntx.Repo,
  url: System.get_env("SNTX_DB"),
  pool_size: 10,
  queue_target: 2000

config :sntx, Sntx.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SNTX_SENDGRID_KEY")

# Do not print debug messages in production
config :logger, level: :info
