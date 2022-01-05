defmodule SntxWeb.Plugs.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    set_language(conn)

    Absinthe.Plug.put_options(conn, context: build_context(conn))
  end

  defp build_context(conn) do
    %{
      user: set_user(conn),
      ip_address: conn.remote_ip |> :inet.ntoa() |> to_string(),
      user_agent: conn |> get_req_header("user-agent") |> List.first(),
      locale: Gettext.get_locale(SntxWeb.Gettext)
    }
  end

  defp set_user(conn) do
    with {:ok, token} <- get_token(conn),
         {:ok, user, _} <- Sntx.Guardian.resource_from_token(token) do
      user
    else
      {:error, _reason} -> nil
      _ -> nil
    end
  end

  defp set_language(conn) do
    language = List.first(get_req_header(conn, "content-language"))
    accepted = Gettext.known_locales(SntxWeb.Gettext)

    if language in accepted do
      Gettext.put_locale(SntxWeb.Gettext, language)
    end
  end

  defp get_token(conn) do
    header = get_req_header(conn, "authorization")
    cookie = conn.req_cookies["sntx-token"]

    cond do
      length(header) > 0 ->
        {:ok,
         header
         |> List.first()
         |> String.split("Bearer ", trim: true)
         |> List.first()}

      !is_nil(cookie) ->
        {:ok, cookie}

      true ->
        nil
    end
  end
end
