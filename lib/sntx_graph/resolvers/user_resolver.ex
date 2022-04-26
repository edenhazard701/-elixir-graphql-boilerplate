defmodule SntxGraph.UserResolver do
  import SntxWeb.Payload

  alias Sntx.{Repo, Guardian, UserMailer}
  alias Sntx.Models.User.{Account, Activations, Auth, Passwords}

  def activate(args, _) do
    with {:ok, user} <- Activations.confirm(args.code),
         {:ok, token, _} <- Guardian.encode_and_sign(user) do
      {:ok, %{token: token}}
    else
      error -> mutation_error_payload(error)
    end
  end

  def activation_resend(args, _) do
    with {:ok, user} <- Auth.user_by_email(args.email),
         true <- Activations.confirmed?(user, :resend) do
      {:ok, validation_message(:user_confirmed)}
    else
      {:error, :unconfirmed, unconfirmed} ->
        UserMailer.resend_activation(unconfirmed)
        {:ok, true}

      error ->
        mutation_error_payload(error)
    end
  end

  def create(%{input: input}, _) do
    with {:ok, user} <- Account.create(input),
         {:ok, user} <- Activations.generate_token(user),
         {:ok, _} <- UserMailer.welcome(user) do
      {:ok, user}
    else
      error -> mutation_error_payload(error)
    end
  end

  def get(%{id: id}, _), do: {:ok, Repo.get(Account, id)}

  def get_current(_, %{context: ctx}), do: {:ok, Repo.get(Account, ctx.user.id)}

  def login(args, _) do
    with {:ok, user} <- Auth.login(args),
         {:ok, token, _} <- Guardian.encode_and_sign(user),
         true <- Activations.confirmed?(user, :login) do
      {:ok, %{token: token}}
    else
      {:error, :unconfirmed, unconfirmed} ->
        UserMailer.resend_activation(unconfirmed)
        {:ok, validation_message(:user_unconfirmed)}

      error ->
        mutation_error_payload(error)
    end
  end

  def logout(args, _) do
    Guardian.revoke(args.token)
    {:ok, true}
  end

  def password_change(args, %{context: ctx}) do
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
  end

  def password_reset(args, _) do
    with {:ok, user} <- Auth.user_by_email(args[:email]),
         {:ok, user} <- Passwords.generate_token(user),
         {:ok, _email} <- UserMailer.reset_password(user) do
      {:ok, true}
    else
      error -> mutation_error_payload(error)
    end
  end

  def password_reset_set_new(args, _) do
    with {:ok, account} <- Passwords.validate_token(args.code),
         {:ok, account} <- Passwords.update(account, args),
         {:ok, token, _} <- Guardian.encode_and_sign(account) do
      {:ok, %{token: token, email: account.email}}
    else
      error -> mutation_error_payload(error)
    end
  end

  def update(%{input: input}, %{context: ctx}) do
    case Account.update(ctx.user, input) do
      {:ok, user} -> {:ok, user}
      error -> mutation_error_payload(error)
    end
  end
end
