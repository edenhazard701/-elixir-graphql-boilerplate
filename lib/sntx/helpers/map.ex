defmodule Sntx.MapHelper do
  @doc """
  Convert map string keys to :atom keys
  """
  def atomize_keys(nil), do: nil

  # Structs don't do enumerable and anyway the keys are already
  # atoms
  def atomize_keys(%{__struct__: _} = struct) do
    struct
  end

  def atomize_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} ->
      if is_binary(k) do
        {String.to_atom(k), atomize_keys(v)}
      else
        {k, atomize_keys(v)}
      end
    end)
    |> Enum.into(%{})
  end

  # Walk the list and atomize the keys of
  # of any map members
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end

  def atomize_keys(not_a_map) do
    not_a_map
  end

  @doc """
  Convert map atom keys to strings
  """
  def stringify_keys(nil), do: nil

  def stringify_keys(%{} = map) do
    map
    |> Enum.map(fn {k, v} -> {Atom.to_string(k), stringify_keys(v)} end)
    |> Enum.into(%{})
  end

  # Walk the list and stringify the keys of
  # of any map members
  def stringify_keys([head | rest]) do
    [stringify_keys(head) | stringify_keys(rest)]
  end

  def stringify_keys(not_a_map) do
    not_a_map
  end

  def merge(list_of_maps) do
    do_merge(list_of_maps, %{})
  end

  defp do_merge([], acc), do: acc

  defp do_merge([head | rest], acc) do
    head = atomize_keys(head)
    updated_acc = Map.merge(acc, head)
    do_merge(rest, updated_acc)
  end

  def dig(nil, _), do: nil
  def dig(struct, []), do: struct

  def dig(struct, [head | tail]) do
    struct
    |> Map.get(head)
    |> dig(tail)
  end

  def from_struct(%{} = map), do: convert_struct(map)

  defp convert_struct(data) when is_struct(data) do
    data
    |> Map.from_struct()
    |> convert_struct()
  end

  defp convert_struct(data) when is_map(data) do
    for {key, value} <- data, reduce: %{} do
      acc ->
        case key do
          :__meta__ ->
            acc

          other ->
            Map.put(acc, other, convert_struct(value))
        end
    end
  end

  defp convert_struct(data) when is_list(data) do
    Enum.map(data, &convert_struct/1)
  end

  defp convert_struct(other), do: other
end
