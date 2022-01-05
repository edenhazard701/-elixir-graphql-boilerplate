defmodule Sntx.Mailer do
  use Bamboo.Mailer, otp_app: :sntx

  import Bamboo.{Email, SendGridHelper}

  require Logger

  @noreply {"Sntx", "sntx@sntx.pl"}

  def prepare(email) do
    new_email()
    |> to(email)
    |> from(@noreply)
  end

  def dispatch(email) do
    if Mix.env() == :dev do
      Logger.info("SendGrid params: #{inspect(email)}")
      {:ok, %Bamboo.Email{}}
    else
      deliver_now(email)
    end
  end

  def generic(email, subject, content) do
    email
    |> prepare()
    |> with_template("d-74a4b48e4e8c4e72bb2cb0190777fa0b")
    |> add_dynamic_field("content", content)
    |> add_dynamic_field("subject", subject)
    |> dispatch()
  end
end
