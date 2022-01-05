defmodule Sntx.Models.User.Activations do
  use Timex

  import Ecto.Changeset
  import Sntx.Models.User.Validations
  import SntxWeb.Gettext

  alias Sntx.Repo
  alias Sntx.Models.User.Account

  def generate_token(%Account{} = user) do
    case save_token(user, :signup, %{
           confirmation_token: SecureRandom.urlsafe_base64(12),
           confirmation_sent_at: DateTime.truncate(Timex.now(), :second)
         }) do
      {:ok, user} -> {:ok, user}
      {:error, reason} -> {:error, reason}
    end
  end

  def confirm(code) do
    code = String.trim(code)
    user = Repo.get_by(Account, confirmation_token: code)

    if user do
      attr = %{
        security_code: code,
        confirmed_at: DateTime.truncate(Timex.now(), :second),
        confirmation_token: nil,
        confirmation_sent_at: nil
      }

      user
      |> cast(attr, [:security_code, :confirmed_at, :confirmation_token, :confirmation_sent_at])
      |> validate_required([:security_code])
      |> validate_already_confirmed([:security_code])
      |> validate_token(user.confirmation_token)
      |> validate_expiration(user.confirmation_sent_at)
      |> Repo.update()
    else
      {:error, dgettext("users", "Invalid or expired activation link.")}
    end
  end

  def confirmed?(%Account{confirmed_at: nil} = user, source) do
    case save_token(user, source, %{
           confirmation_token: SecureRandom.urlsafe_base64(12),
           confirmation_sent_at: DateTime.truncate(Timex.now(), :second)
         }) do
      {:ok, user} -> {:error, :unconfirmed, user}
      {:error, reason} -> {:error, reason}
    end
  end

  def confirmed?(%Account{}, _), do: true

  defp save_token(%Account{} = user, source, attr) do
    user
    |> cast(attr, [:confirmation_token, :confirmation_sent_at])
    |> validate_required([:confirmation_token, :confirmation_sent_at])
    |> validate_already_confirmed([:security_code])
    |> validate_timeout(source, :confirmation_sent_at)
    |> Repo.update()
  end

  defp validate_already_confirmed(changeset, _field) do
    if changeset.valid? && changeset.data.confirmed_at do
      add_error(changeset, :base, dgettext("users", "User has been already confirmed"))
    else
      changeset
    end
  end
end
