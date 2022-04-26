defmodule SntxWeb.Payload do
  alias AbsintheErrorPayload.ValidationMessage
  import SntxWeb.Gettext

  def validation_message(), do: default_error() |> validation_message()

  def validation_message(msg) when is_atom(msg) do
    msg
    |> default_error()
    |> validation_message()
  end

  def validation_message(msg, field \\ "base") when is_binary(msg) do
    %ValidationMessage{
      code: :unknown,
      field: field,
      template: msg,
      message: msg,
      options: []
    }
  end

  def default_error(code \\ :unexpected_error) do
    case code do
      :no_access -> dgettext("global", "Access denied")
      :no_user -> dgettext("users", "Account does not exist")
      :no_permissions -> dgettext("global", "Insufficient permissions")
      :user_unconfirmed -> dgettext("users", "You must confirm your account")
      :user_confirmed -> dgettext("users", "Account has been already confirmed")
      :invalid_credentials -> dgettext("users", "Invalid email or password")
      _ -> dgettext("global", "Unexpected error. Please contact support@sntx.pl")
    end
  end

  def mutation_error_payload(error) do
    case error do
      %Ecto.Changeset{} = changeset ->
        {:ok, changeset}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:ok, changeset}

      {:error, _, %Ecto.Changeset{} = changeset, _} ->
        {:ok, changeset}

      {:error, error} ->
        {:ok, validation_message(error)}

      _ ->
        {:ok, validation_message()}
    end
  end
end
