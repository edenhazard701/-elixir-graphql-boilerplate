defmodule Sntx.UserMailer do
  import Bamboo.SendGridHelper

  alias Sntx.Mailer

  @web_url Application.fetch_env!(:sntx, :web_url)

  def welcome(user) do
    Mailer.prepare(user.email)
    |> with_template("d-04f2eb84554441889374efb487bcffe9")
    |> add_dynamic_field("full_name", full_name(user))
    |> add_dynamic_field("verify_url", activation_link(user))
    |> Mailer.dispatch()
  end

  def resend_activation(user) do
    Mailer.prepare(user.email)
    |> with_template("d-455f25950c8d4053b4a592cc81e380e6")
    |> add_dynamic_field("full_name", full_name(user))
    |> add_dynamic_field("verify_url", activation_link(user))
    |> Mailer.dispatch()
  end

  def reset_password(user) do
    Mailer.prepare(user.email)
    |> with_template("d-4bce6142193a456f928a492538be26fe")
    |> add_dynamic_field("reset_url", password_reset_link(user))
    |> Mailer.dispatch()
  end

  def join(invitation, organization) do
    Mailer.prepare(invitation.email)
    |> with_template("d-88f1bb6e076f489e942926def485f3a2")
    |> add_dynamic_field("join_url", invitation_link(invitation))
    |> add_dynamic_field("organization_name", organization.name)
    |> Mailer.dispatch()
  end

  def join_member(member, organization) do
    Mailer.prepare(member.user.email)
    |> with_template("d-0e99716a4f5c412bba709aaa083a4350")
    |> add_dynamic_field("full_name", full_name(member.user))
    |> add_dynamic_field("join_url", member_invitation_link(member))
    |> add_dynamic_field("organization_name", organization.name)
    |> Mailer.dispatch()
  end

  defp activation_link(user) do
    "#{@web_url}/user/activate/#{user.confirmation_token}"
  end

  defp full_name(user) do
    "#{user.first_name} #{user.last_name}"
  end

  defp password_reset_link(user) do
    "#{@web_url}/user/reset-password/#{user.reset_password_token}"
  end

  defp invitation_link(invitation) do
    "#{@web_url}/join/#{invitation.id}"
  end

  defp member_invitation_link(member) do
    "#{@web_url}/join/member/#{member.id}"
  end
end
