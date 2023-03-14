defmodule SntxGraph.BlogQueries do
  use Absinthe.Schema.Notation

  alias SntxGraph.Middleware.Authorize
  alias SntxGraph.BlogResolver

  object :blog_queries do

    field :blog_list, :blog_list do
      middleware(Authorize)
      resolve(&BlogResolver.get_list/2)
    end

    field :blog_single, :blog_single do
      arg :text, :string

      middleware(Authorize)
      resolve(&BlogResolver.get_by_title/2)
    end
  end
end
