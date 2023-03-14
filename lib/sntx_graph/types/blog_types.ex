defmodule SntxGraph.BlogTypes do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  alias Sntx.Blog.Post

  payload_object(:blog_post_payload, :blog_post)

  input_object :blog_post_create_input do
    import_fields(:blog_post_input)
  end

  input_object :blog_post_update_input do
    import_fields(:blog_post_input)

    field :post_id, :uuid4
  end

  input_object :blog_post_input do
    field :title, :string
    field :body, :string
  end

  object :blog_post do
    field :title, :string
    field :body, :string
    field :author, :uuid4
  end
end
