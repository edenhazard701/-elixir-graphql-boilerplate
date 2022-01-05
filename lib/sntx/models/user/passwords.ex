defmodule Sntx.Models.User.Passwords do
  use Timex

  import Ecto.Changeset
  import Sntx.Models.User.Validations
  import SntxWeb.Gettext

  alias Sntx.Repo
  alias Sntx.Models.User.Account

  def update(user, %{password: password}) do
    user
    |> Account.changeset(%{password: password})
    |> change(%{reset_password_count: 0})
    |> Repo.update()
  end

  def generate_token(user) do
    case save_token(user, %{
           reset_password_token: SecureRandom.urlsafe_base64(12),
           reset_password_sent_at: DateTime.truncate(Timex.now(), :second)
         }) do
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_token(code) do
    code = String.trim(code)
    user = Repo.get_by(Account, reset_password_token: code)

    if user do
      attr = %{
        security_code: code,
        reset_password_token: nil,
        reset_password_sent_at: nil
      }

      user
      |> cast(attr, [:security_code, :reset_password_token, :reset_password_sent_at])
      |> validate_required([:security_code])
      |> validate_token(user.reset_password_token)
      |> validate_expiration(user.reset_password_sent_at)
      |> Repo.update()
    else
      {:error, dgettext("userss", "Token is not valid")}
    end
  end

  defp save_token(user, attr) do
    user
    |> cast(attr, [:reset_password_token, :reset_password_sent_at])
    |> validate_required([:reset_password_token, :reset_password_sent_at])
    |> validate_trigger_counter()
    |> Repo.update()
  end

  defp validate_trigger_counter(%{data: data} = user) do
    if data.reset_password_count >= 5 do
      validate_timeout(user, :password, :reset_password_sent_at)
    else
      change(user, %{reset_password_count: data.reset_password_count + 1})
    end
  end
end
