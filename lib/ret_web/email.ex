defmodule RetWeb.Email do
  use Bamboo.Phoenix, view: RetWeb.EmailView
  alias Ret.{AppConfig}

  def auth_email(signin_args) do
    custom_login_body = AppConfig.get_cached_config_value("auth|login_body")

    if string_is_nil_or_empty(custom_login_body),
      do:
        "#{RetWeb.Endpoint.url()}/?#{URI.encode_query(signin_args)}",
      else: add_magic_link_to_custom_login_body(custom_login_body, signin_args)

  end

  defp string_is_nil_or_empty(check_string) do
    check_string == nil || String.length(String.trim(check_string)) == 0
  end

  defp add_magic_link_to_custom_login_body(custom_message, signin_args) do
    magic_link = "#{RetWeb.Endpoint.url()}/?#{URI.encode_query(signin_args)}"

    if Regex.match?(~r/{{ link }}/, custom_message) do
      Regex.replace(~r/{{ link }}/, custom_message, magic_link)
    else
      custom_message <> "\n\n" <> magic_link
    end
  end

  def enabled? do
    !!Application.get_env(:ret, Ret.Mailer)[:adapter]
  end
end
