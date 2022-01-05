defmodule SntxWeb.BaseController do
  use SntxWeb, :controller

  def index(conn, _params) do
    {:ok, vsn} = :application.get_key(:sntx, :vsn)

    json(conn, %{status: :ok, version: List.to_string(vsn)})
  end
end
