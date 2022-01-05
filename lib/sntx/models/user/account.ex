defmodule Sntx.Models.User.Account do
  use Sntx.Models
  use Waffle.Ecto.Schema

  import Ecto.{Changeset, Query}
  import SntxWeb.Gettext

  alias __MODULE__, as: Account
  alias Sntx.{Repo, Uploaders}
  alias Sntx.Services.Uploads

  schema "user_accounts" do
    field :email, :string
    field :password_hash, :string
    field :role, UserAccountRole, default: :user

    field :first_name, :string
    field :last_name, :string
    field :avatar, Uploaders.Avatar.Type

    field :confirmation_token, :string
    field :confirmation_sent_at, :utc_datetime
    field :confirmed_at, :utc_datetime

    field :reset_password_token, :string
    field :reset_password_sent_at, :utc_datetime
    field :reset_password_count, :integer

    field :security_code, :string, virtual: true
    field :password, :string, virtual: true
    field :remove_avatar, :boolean, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:avatar, :remove_avatar, :first_name, :last_name, :password])
    |> validate_length(:first_name, min: 2, max: 24)
    |> validate_length(:last_name, min: 2, max: 24)
    |> unique_constraint(:email, downcase: true)
    |> put_password_hash()
  end

  def changeset_avatar(user, attrs) do
    Uploads.changeset(user, attrs, field: :avatar, uploader: Uploaders.Avatar)
  end

  def create(attrs) do
    remove_existing_unconfirmed(attrs)

    %Account{}
    |> changeset(attrs)
    |> cast(attrs, [:email])
    |> validate_required([:email, :password])
    |> validate_length(:password, min: 8, max: 64)
    |> validate_email()
    |> Repo.insert()
    |> Uploads.create(attrs, &changeset_avatar/2)
  end

  def get(id) do
    case Repo.get_by(Account, id: id) do
      nil -> {:error, dgettext("global", "User not found")}
      organization -> {:ok, organization}
    end
  end

  def public_email(user, _args, _ctx) do
    arr = String.split(user.email, "@")
    len = arr |> List.first() |> String.length()
    domain = arr |> List.last()

    {:ok, "#{String.at(user.email, 0)}#{String.duplicate("*", len - 1)}@#{domain}"}
  end

  def update(user, attrs) do
    user
    |> changeset(attrs)
    |> changeset_avatar(attrs)
    |> Repo.update()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end

  defp remove_existing_unconfirmed(attrs) do
    max = Timex.shift(Timex.now(), hours: -Application.fetch_env!(:sntx, :unconfirmed_expire_hours))

    user =
      Account
      |> where(
        [p],
        p.confirmation_sent_at < ^max and
          is_nil(p.confirmed_at) and
          p.email == ^attrs[:email]
      )
      |> first([:inserted_at, :id])
      |> Repo.one()

    !is_nil(user) && Repo.delete(user)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: dgettext("users", "must have the @ sign and no spaces"))
    |> validate_length(:email, max: 160)
  end
end
