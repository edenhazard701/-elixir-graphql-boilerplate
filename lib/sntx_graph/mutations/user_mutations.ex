defmodule SntxGraph.UserMutations do
  use Absinthe.Schema.Notation

  alias SntxGraph.Middleware.Authorize
  alias SntxGraph.UserResolver

  object :user_mutations do
    field :user_create, :user_account_payload do
      arg :input, non_null(:user_account_create_input)

      resolve(&UserResolver.create/2)
    end

    field :user_update, :user_account_payload do
      arg :input, non_null(:user_account_input)

      middleware(Authorize)
      resolve(&UserResolver.update/2)
    end

    field :user_login, type: :user_session_payload do
      arg :email, non_null(:string)
      arg :password, non_null(:string)

      resolve(&UserResolver.login/2)
    end

    field :user_logout, type: :boolean_payload do
      arg :token, non_null(:string)

      resolve(&UserResolver.logout/2)
    end

    @desc "User account activation using token from link in email"
    field :user_activate, :user_session_payload do
      arg :code, non_null(:string)

      resolve(&UserResolver.activate/2)
    end

    @desc "Activation email resending (15 minutes treshold)"
    field :user_resend_activation, :boolean_payload do
      arg :email, non_null(:string)

      resolve(&UserResolver.activation_resend/2)
    end

    field :user_password_change, :user_account_payload do
      arg :password, :string
      arg :current_password, :string

      middleware(Authorize)
      resolve(&UserResolver.password_change/2)
    end

    field :user_password_reset, :boolean_payload do
      arg :email, :string

      resolve(&UserResolver.password_reset/2)
    end

    field :user_password_reset_new, :user_session_payload do
      arg :code, non_null(:string)
      arg :password, :string
      arg :password_confirmation, :string

      resolve(&UserResolver.password_reset_set_new/2)
    end
  end
end
