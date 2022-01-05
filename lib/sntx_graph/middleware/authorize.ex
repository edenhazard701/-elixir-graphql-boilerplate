defmodule SntxGraph.Middleware.Authorize do
  @behaviour Absinthe.Middleware
  import SntxWeb.{Gettext, Payload}

  def call(%{context: ctx} = res, config) do
    cond do
      is_nil(ctx.user) ->
        Absinthe.Resolution.put_result(
          res,
          {:error, dgettext("global", "You must be logged in to perform this action")}
        )

      config[:admin] == true and ctx.user.role == :administrator ->
        res

      config[:admin] != true ->
        res

      true ->
        Absinthe.Resolution.put_result(
          res,
          {:error, default_error(:no_access)}
        )
    end
  end
end
