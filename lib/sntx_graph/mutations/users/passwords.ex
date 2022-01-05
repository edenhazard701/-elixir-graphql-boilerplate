defmodule SntxGraph.Mutations.Users.Passwords do
  use Absinthe.Schema.Notation

  import SntxWeb.Payload

  alias Sntx.Guardian
  alias Sntx.Models.User.{Auth, Passwords, Mail}
  alias SntxGraph.Middleware.Authorize

  object :user_password_mutations do
    field :user_password_change, :user_account_payload do
      arg :password, :string
      arg :current_password, :string

      middleware(Authorize)

      resolve(fn args, %{context: ctx} ->
        params = %{
          email: ctx.user.email,
          password: args.current_password
        }

        with {:ok, user} <- Auth.login(params),
             {:ok, user} <- Passwords.update(user, args) do
          {:ok, user}
        else
          error -> mutation_error_payload(error)
        end
      end)
    end

    field :user_password_reset, :boolean_payload do
      arg :email, :string

      resolve(fn args, _ ->
        with {:ok, user} <- Auth.user_by_email(args[:email]),
             {:ok, user} <- Passwords.generate_token(user),
             {:ok, _email} <- Mail.reset_password(user) do
          {:ok, true}
        else
          error -> mutation_error_payload(error)
        end
      end)
    end

    field :user_password_reset_new, :user_session_payload do
      arg :code, non_null(:string)
      arg :password, :string
      arg :password_confirmation, :string

      resolve(fn args, _ ->
        with {:ok, account} <- Passwords.validate_token(args.code),
             {:ok, account} <- Passwords.update(account, args),
             {:ok, token, _} <- Guardian.encode_and_sign(account) do
          {:ok, %{token: token}}
        else
          error -> mutation_error_payload(error)
        end
      end)
    end
  end
end
