defmodule SntxGraph.CustomTypes do
  use Absinthe.Schema.Notation

  import AbsintheErrorPayload.Payload

  payload_object(:boolean_payload, :boolean)
end
