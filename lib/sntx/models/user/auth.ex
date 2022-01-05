defmodule Sntx.Models.User.Auth do
  import Ecto.Query
  import SntxWeb.Payload

  alias Sntx.Repo
  alias Sntx.Models.User.Account

  def user_by_email(nil), do: {:error, default_error(:invalid_credentials)}

  def user_by_email(email) do
    case find_user(email) do
      nil -> {:error, default_error(:no_user)}
      user -> {:ok, user}
    end
  end

  def login(nil), do: {:error, default_error(:invalid_credentials)}

  def login(attrs) do
    user = find_user(attrs.email)

    if !is_nil(user) && Argon2.verify_pass(attrs.password, user.password_hash) do
      {:ok, user}
    else
      {:error, default_error(:invalid_credentials)}
    end
  end

  defp clean_email(email) do
    email
    |> String.downcase()
    |> String.trim()
  end

  defp find_user(email) do
    from(a in Account, where: fragment("lower(?)", a.email) == ^clean_email(email))
    |> first([:inserted_at, :id])
    |> Repo.one()
  end
end
