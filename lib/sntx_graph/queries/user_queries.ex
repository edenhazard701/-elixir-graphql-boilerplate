defmodule SntxGraph.UserQueries do
  use Absinthe.Schema.Notation

  alias SntxGraph.Middleware.Authorize
  alias SntxGraph.UserResolver

  object :user_queries do
    @desc "Current account. Null when user is guest/banned/deleted"
    field :user_current, :user_account do
      middleware(Authorize)
      resolve(&UserResolver.get_current/2)
    end

    field :user_profile, :user_public_account do
      arg :id, :uuid4

      middleware(Authorize)
      resolve(&UserResolver.get/2)
    end
  end
end
