defmodule SntxWeb.UserSocket do
  use Phoenix.Socket
  use Absinthe.Phoenix.Socket, schema: SntxWebGraph.Schema

  def connect(params, socket) do
    with false <- is_nil(params["Authorization"]),
         "Bearer " <> token <- params["Authorization"],
         {:ok, user, _} <- Sntx.Guardian.resource_from_token(token) do
      socket =
        Absinthe.Phoenix.Socket.put_options(socket,
          context: %{
            user: user
          }
        )

      {:ok, socket}
    else
      {:error, error} ->
        {:error, error}

      _ ->
        :error
    end
  end

  def id(_socket), do: nil
end
