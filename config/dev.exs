import Config

# Configure your database
config :sntx, Sntx.Repo,
  url: System.get_env("SNTX_DB"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 20,
  queue_target: 5000

config :sntx, SntxWeb.Endpoint,
  http: [port: System.get_env("SNTX_PORT")],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

config :sntx, Sntx.Mailer,
  adapter: Bamboo.LocalAdapter,
  open_email_in_browser_url: "http://localhost:#{System.get_env("SNTX_PORT")}/sent_emails"

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n", level: :debug

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime
