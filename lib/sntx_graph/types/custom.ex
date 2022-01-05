defmodule SntxGraph.Types.Custom do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  payload_object(:boolean_payload, :boolean)
end
