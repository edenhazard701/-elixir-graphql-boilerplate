defmodule Sntx.Models.User.Validations do
  import Ecto.Changeset
  import SntxWeb.{Payload, Gettext}

  def validate_token(changeset, field) do
    if changeset.valid? && field != changeset.changes.security_code do
      add_error(changeset, :base, dgettext("users", "Invalid code"))
    else
      changeset
    end
  end

  def validate_expiration(changeset, field) do
    token_expire_hours = Application.fetch_env!(:sntx, :token_expire_hours)

    if changeset.valid? && expired?(field, hours: token_expire_hours) do
      add_error(changeset, :base, dgettext("users", "Code has expired"))
    else
      changeset
    end
  end

  # Timeout between confirmation emails
  def validate_timeout(changeset, source, field) do
    treshold = 15

    cmp =
      if Map.get(changeset.data, field) do
        shift(Map.get(changeset.data, field), minutes: treshold)
      end

    if is_nil(Map.get(changeset.data, field)) or Timex.compare(cmp, Timex.now()) == -1 do
      changeset
    else
      if source == :login do
        add_error(changeset, :base, default_error(:user_unconfirmed))
      else
        time = Timex.diff(cmp, Timex.now(), :minutes)

        add_error(
          changeset,
          :base,
          dngettext("users", "Try again in a minute", "Try again in %{count} minutes", time)
        )
      end
    end
  end

  defp expired?(nil, _), do: true

  defp expired?(datetime, opts) do
    not Timex.before?(Timex.now(), shift(datetime, opts))
  end

  defp shift(datetime, opts) do
    datetime
    |> NaiveDateTime.to_erl()
    |> Timex.to_datetime()
    |> Timex.shift(opts)
  end
end
