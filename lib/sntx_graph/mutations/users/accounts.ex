defmodule SntxGraph.Mutations.Users.Accounts do
  use Absinthe.Schema.Notation

  import SntxWeb.Payload

  alias Sntx.Models.User.{Account, Activations, Mail}
  alias SntxGraph.Middleware.Authorize

  object :user_account_mutations do
    field :user_create, :user_account_payload do
      arg :input, non_null(:user_account_create_input)
      arg :invitation_id, :uuid4

      resolve(fn %{input: input}, _ ->
        with {:ok, user} <- Account.create(input),
             {:ok, user} <- Activations.generate_token(user),
             {:ok, _} <- Mail.welcome(user) do
          {:ok, user}
        else
          error -> mutation_error_payload(error)
        end
      end)
    end

    field :user_update, :user_account_payload do
      arg :input, non_null(:user_account_input)
      middleware(Authorize)

      resolve(fn %{input: input} = _args, %{context: ctx} ->
        case Account.update(ctx.user, input) do
          {:ok, user} -> {:ok, user}
          error -> mutation_error_payload(error)
        end
      end)
    end
  end
end
