defmodule SntxWeb.Router do
  use SntxWeb, :router

  import Phoenix.LiveDashboard.Router

  pipeline :api do
    plug CORSPlug, origin: "*"
    plug :accepts, ["json", "html"]
    plug SntxWeb.Plugs.Context
    plug SntxWeb.Plugs.Pipeline
  end

  scope "/" do
    pipe_through :api

    get "/", SntxWeb.BaseController, :index

    if Mix.env() == :dev do
      forward "/sent_emails", Bamboo.SentEmailViewerPlug
    end

    if System.get_env("SNTX_DASHBOARD") == "1" do
      live_dashboard "/dashboard", metrics: SntxWeb.Telemetry, ecto_repos: [Sntx.Repo]
    end

    if System.get_env("SNTX_GRAPHIQL") == "1" do
      forward "/graphiql", Absinthe.Plug.GraphiQL,
        schema: SntxGraph.Schema,
        socket: SntxWeb.UserSocket,
        interface: :advanced
    end

    forward "/graphql", Absinthe.Plug, schema: SntxGraph.Schema, json_codec: Jason

    get "/*path", SntxWeb.BaseController, :index
  end
end
