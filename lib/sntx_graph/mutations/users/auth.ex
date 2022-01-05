defmodule SntxGraph.Mutations.Users.Auth do
  use Absinthe.Schema.Notation

  import SntxWeb.Payload

  alias Sntx.Guardian
  alias Sntx.Models.User.{Auth, Activations, Mail}

  object :user_auth_mutations do
    field :user_login, type: :user_session_payload do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve(fn args, _ ->
        with {:ok, user} <- Auth.login(args),
             {:ok, token, _} <- Guardian.encode_and_sign(user),
             true <- Activations.confirmed?(user, :login) do
          {:ok, %{token: token}}
        else
          {:error, :unconfirmed, unconfirmed} ->
            Mail.resend_activation(unconfirmed)
            {:ok, message_payload(:user_unconfirmed)}

          error ->
            mutation_error_payload(error)
        end
      end)
    end

    field :user_logout, type: :boolean_payload do
      arg :token, non_null(:string)

      resolve(fn args, _ ->
        Guardian.revoke(args.token)
        {:ok, true}
      end)
    end

    @desc "User account activation using token from link in email"
    field :user_activate, :user_session_payload do
      arg :code, non_null(:string)

      resolve(fn args, _ ->
        with {:ok, user} <- Activations.confirm(args.code),
             {:ok, token, _} <- Guardian.encode_and_sign(user) do
          {:ok, %{token: token, email: user.email}}
        else
          error -> mutation_error_payload(error)
        end
      end)
    end

    @desc "Activation email resending (15 minutes treshold)"
    field :user_resend_activation, :boolean_payload do
      arg :email, non_null(:string)

      resolve(fn args, _ ->
        with {:ok, user} <- Auth.user_by_email(args.email),
             true <- Activations.confirmed?(user, :resend) do
          {:ok, message_payload(:user_confirmed)}
        else
          {:error, :unconfirmed, unconfirmed} ->
            Mail.resend_activation(unconfirmed)
            {:ok, true}

          error ->
            mutation_error_payload(error)
        end
      end)
    end
  end
end
