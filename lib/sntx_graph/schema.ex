defmodule SntxGraph.Schema do
  use Absinthe.Schema
  import AbsintheErrorPayload.Payload

  alias SntxGraph.Middleware.TranslatePayload
  alias SntxGraph.{Types, Mutations, Queries, Scalars}

  import_types(Absinthe.Plug.Types)
  import_types(Absinthe.Type.Custom)
  import_types(AbsintheErrorPayload.ValidationMessageTypes)

  import_types(Scalars.UUID4)
  import_types(Scalars.JSON)

  import_types(Types.CustomTypes)
  import_types(Types.UserTypes)

  import_types(Mutations.UserMutations)
  import_types(Queries.UserQueries)

  mutation do
    import_fields(:user_mutations)
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
    alias SntxGraph.Middleware.{BasicDataloader, PositionDataloader}

    loader =
      Dataloader.new(get_policy: :return_nil_on_error)
      |> Dataloader.add_source(BasicDataloader, BasicDataloader.data())
      |> Dataloader.add_source(PositionDataloader, PositionDataloader.data())

    Map.put(ctx, :loader, loader)
  end
end
