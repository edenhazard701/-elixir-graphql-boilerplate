# General application configuration
import Config

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :sntx,
  ecto_repos: [Sntx.Repo],
  generators: [binary_id: true],
  token_expire_hours: 12,
  unconfirmed_expire_hours: 4,
  web_url: System.get_env("SNTX_WEB_URL")

# Configures the endpoint
config :sntx, SntxWeb.Endpoint,
  render_errors: [view: SntxWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: Sntx.PubSub,
  secret_key_base: System.get_env("SNTX_SECRET_BASE"),
  live_view: [signing_salt: System.get_env("SNTX_SIGNING_SALT")]

# Json Web Token
config :sntx, Sntx.Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "Sntx-API",
  ttl: {30, :days},
  allowed_drift: 2000,
  verify_issuer: true,
  serializer: Sntx.Guardian,
  secret_key: %{"k" => System.get_env("SNTX_GUARDIAN_KEY"), "kty" => "oct"}

config :sntx, SntxWeb.Gettext,
  default_locale: "en",
  split_module_by: [:locale]

config :guardian, Guardian.DB,
  repo: Sntx.Repo,
  schema_name: "user_tokens",
  sweep_interval: 3600

# Configures Elixir's Logger
config :logger,
  backends: [:console, Sentry.LoggerBackend]

config :sentry,
  dsn: System.get_env("SNTX_SENTRY_DSN"),
  included_environments: [:prod],
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!()

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
