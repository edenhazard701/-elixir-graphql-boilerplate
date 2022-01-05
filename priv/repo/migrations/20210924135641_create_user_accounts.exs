defmodule Sntx.Repo.Migrations.CreateUserAccounts do
  use Ecto.Migration

  def change do
    UserAccountRole.create_type()

    create table(:user_accounts, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")

      add :email, :string
      add :password_hash, :string
      add :role, UserAccountRole.type()

      add :first_name, :string
      add :last_name, :string
      add :avatar, :string

      add :confirmation_token, :string
      add :confirmation_sent_at, :utc_datetime
      add :confirmed_at, :utc_datetime

      add :reset_password_token, :string
      add :reset_password_sent_at, :utc_datetime
      add :reset_password_count, :integer

      timestamps()
    end

    create(unique_index(:user_accounts, ["(lower(email))"]))
  end
end
