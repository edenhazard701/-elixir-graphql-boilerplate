defmodule SntxGraph.Queries.Users do
  use Absinthe.Schema.Notation

  alias Sntx.Repo
  alias Sntx.Models.User.Account
  alias SntxGraph.Middleware.Authorize

  object :user_queries do
    @desc "Current account. Null when user is guest/banned/deleted"
    field :user_current, :user_account do
      middleware(Authorize)

      resolve(fn _, %{context: ctx} ->
        {:ok, Repo.get(Account, ctx.user.id)}
      end)
    end

    field :user_profile, :user_public_account do
      arg :id, :uuid4
      middleware(Authorize)

      resolve(fn args, _ ->
        {:ok, Repo.get(Account, args.id)}
      end)
    end
  end
end
