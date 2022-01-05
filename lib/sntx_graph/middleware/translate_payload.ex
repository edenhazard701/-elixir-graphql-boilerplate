defmodule SntxGraph.Middleware.TranslatePayload do
  @behaviour Absinthe.Middleware

  def call(%{value: value} = resolution, _config) do
    result = do_translate_messages(value)
    Absinthe.Resolution.put_result(resolution, {:ok, result})
  end

  defp do_translate_messages(%AbsintheErrorPayload.Payload{} = payload) do
    Map.update!(payload, :messages, fn messages ->
      Enum.map(messages, &translate_message/1)
    end)
  end

  defp do_translate_messages(value), do: value

  # Supports column translations too (field)
  defp translate_message(%AbsintheErrorPayload.ValidationMessage{} = validation_message) do
    opts = Map.get(validation_message, :options)
    template = Map.get(validation_message, :template)
    parsed = Enum.reduce(opts, %{}, fn v, acc -> Map.put(acc, v[:key], v[:value]) end)

    validation_message
    |> Map.update!(:message, fn _message ->
      cond do
        opts[:count] ->
          Gettext.dngettext(SntxWeb.Gettext, "ecto", template, template, opts[:count], parsed)

        Enum.empty?(opts) ->
          Gettext.dgettext(SntxWeb.Gettext, "ecto", template)

        true ->
          Gettext.dgettext(SntxWeb.Gettext, "ecto", template, parsed)
      end
    end)
    |> Map.update!(:field, fn field ->
      case field do
        "base" -> field
        nil -> nil
        _ -> Gettext.dgettext(SntxWeb.Gettext, "ecto", field)
      end
    end)
  end
end
