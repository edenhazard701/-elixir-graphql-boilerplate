defmodule SntxGraph.Schema do
  use Absinthe.Schema
  import AbsintheErrorPayload.Payload

  alias SntxGraph.Middleware.TranslatePayload
  alias SntxGraph.{Types, Mutations, Queries, Schema}

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(AbsintheErrorPayload.ValidationMessageTypes)

  import_types(Schema.Custom)
  import_types(Schema.User)

  import_types(Types.UUID4)
  import_types(Types.Json)

  import_types(Mutations.Users.Accounts)
  import_types(Mutations.Users.Auth)
  import_types(Mutations.Users.Passwords)

  import_types(Queries.Users)

  mutation do
    import_fields(:user_account_mutations)
    import_fields(:user_auth_mutations)
    import_fields(:user_password_mutations)
  end

  query do
    import_fields(:user_queries)
  end

  def middleware(middleware, _field, %Absinthe.Type.Object{identifier: :mutation}) do
    middleware ++ [&build_payload/2, TranslatePayload]
  end

  def middleware(middleware, _field, _object) do
    middleware
  end

  def plugins do
    [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]
  end

  def context(ctx) do
    alias SntxGraph.{BasicDataloader, PositionDataloader}

    loader =
      Dataloader.new(get_policy: :return_nil_on_error)
      |> Dataloader.add_source(BasicDataloader, BasicDataloader.data())
      |> Dataloader.add_source(PositionDataloader, PositionDataloader.data())

    Map.put(ctx, :loader, loader)
  end
end
