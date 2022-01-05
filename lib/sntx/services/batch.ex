defmodule Sntx.Services.Batch do
  import Ecto.Changeset

  alias Sntx.Repo

  def save({:error, changeset}, _, _), do: {:error, changeset}

  def save({:ok, parent}, attrs, opts) do
    parent
    |> change()
    |> changeset(attrs, opts)
    |> Repo.update()
  end

  @doc """
  Updating provided data only.
  Ecto requires full batch or it deletes records.

  ## Options
      :assoc_name - name of assocation from schema
      :module - Associated module name
      :key - (default :id), any number/string field can be used
      :strategy - (:destroy/:flag, default: :flag)

  """
  def changeset(parent, nil, _), do: parent
  def changeset(parent, {:error, message}, opts), do: add_error(parent, opts[:assoc_name], message)
  def changeset(%Ecto.Changeset{valid?: false} = parent, _, _), do: parent

  def changeset(parent, attrs, opts) do
    parent = %Ecto.Changeset{parent | data: Repo.preload(parent.data, opts[:assoc_name])}
    items = Map.get(parent.data, opts[:assoc_name]) || []

    # List of changed/added
    attrs = prepare_attributes(attrs, parent, opts)

    changed =
      attrs
      |> Enum.map(& &1.data.id)
      |> Enum.reject(&is_nil/1)

    unchanged = Enum.filter(items, fn item -> !Enum.member?(changed, item.id) end)

    all = attrs ++ unchanged

    all =
      if opts[:strategy] == :destroy do
        Enum.reject(
          all,
          &(Map.has_key?(&1, :changes) and
              Map.has_key?(&1.changes, :deleted) and
              &1.changes.deleted)
        )
      else
        all
      end

    put_assoc(parent, opts[:assoc_name], all)
  end

  defp prepare_attributes(attrs, parent, opts) do
    items = Map.get(parent.data, opts[:assoc_name])
    Enum.map(attrs, &parse_single_attr(&1, items, opts))
  end

  defp parse_single_attr(attr, items, opts) do
    # Use id if key is not provided
    key = (is_nil(opts[:key]) && :id) || opts[:key]
    empty_struct = struct(opts[:module])
    id = Map.get(attr, key)

    # This should be enough to avoid database quering
    existing =
      unless is_nil(id) do
        Enum.find(items, &(to_string(Map.get(&1, key)) == to_string(id)))
      end

    # 1 - new record, 2 - existing, 3 - with invalid id/key
    cond do
      !is_nil(existing) ->
        apply(opts[:module], :changeset, [existing, attr])

      is_nil(existing) ->
        apply(opts[:module], :changeset, [empty_struct, Map.delete(attr, :id)])

      true ->
        opts[:module]
        |> apply(:changeset, [empty_struct, attr])
        |> add_error(key, "invalid id")
    end
  end
end
