defmodule SntxGraph.UserTypes do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  alias Sntx.Uploaders
  alias Sntx.Models.User.Account

  payload_object(:user_account_payload, :user_account)
  payload_object(:user_session_payload, :user_session)

  input_object :user_account_create_input do
    import_fields(:user_account_input)

    field :password, :string
  end

  input_object :user_account_input do
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :upload_avatar, :upload
    field :remove_avatar, :boolean, default_value: false
  end

  object :user_account do
    import_fields(:user_public_account)

    field :email, :string
    field :role, :string
    field :inserted_at, :naive_datetime
  end

  object :user_public_account do
    field :id, :uuid4
    field :first_name, :string
    field :last_name, :string
    field :public_email, :string, resolve: &Account.public_email/3

    field :avatar, :string do
      arg(:format, :string, default_value: "small")

      resolve(fn %{avatar: avatar} = account, %{format: format}, _ ->
        {:ok, Uploaders.Avatar.url({avatar, account}, String.to_atom(format))}
      end)
    end
  end

  object :user_session do
    field :token, :string
  end
end
