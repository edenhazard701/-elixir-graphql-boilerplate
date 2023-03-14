defmodule SntxGraph.BlogMutations do
  use Absinthe.Schema.Notation

  alias SntxGraph.Middleware.Authorize
  alias SntxGraph.BlogResolver

  object :blog_mutations do
    field :blog_post_create, :blog_post_payload do
      arg :input, non_null(:blog_post_create_input)

      middleware(Authorize)
      resovle(&BlogResolver.create/2)
    end

    field :blog_post_update, type: :boolean_payload do
      arg :input, non_null(:blog_post_update_input)

      resolve(&BlogResolver.update/2)
    end

    field :blog_post_delete type: :boolean_payload do
      arg :post_id, non_null(:uuid4)

      resolve(&BlogResolver.delete/2)
    end
  end
end
