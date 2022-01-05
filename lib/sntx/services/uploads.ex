defmodule Sntx.Services.Uploads do
  import Ecto.Changeset

  use Waffle.Ecto.Schema

  alias Sntx.Repo

  def create({:error, changeset}, _, _), do: {:error, changeset}

  # For new records. Waffle requires existing id before uploading.
  # In case of fail upload function destroys record
  # (if policy is set to :destroy).
  def create({:ok, struct}, attrs, changeset_fun, policy \\ :destroy) do
    case struct
         |> change()
         |> changeset_fun.(attrs)
         |> Repo.update() do
      {:ok, struct} ->
        {:ok, struct}

      {:error, error} ->
        if policy == :destroy, do: Repo.delete(struct)

        {:error, error}
    end
  end

  def changeset(%Ecto.Changeset{valid?: false} = changeset, _, _), do: changeset

  def changeset(changeset, attrs, opts) do
    remove_field = String.to_atom("remove_#{opts[:field]}")
    upload_field = String.to_atom("upload_#{opts[:field]}")

    # Skip when new record/invalid changeset
    cond do
      !changeset.data.id ->
        changeset

      attrs |> Map.get(upload_field) |> is_nil() == false ->
        attrs =
          attrs
          |> Map.get(upload_field)
          |> prepare_file(opts)

        if attrs |> Map.get(opts[:field]) |> is_nil() == false do
          cast_attachments(changeset, attrs, [opts[:field]])
        else
          changeset
        end

      Map.get(attrs, remove_field) == true ->
        changeset
        |> put_change(opts[:field], nil)
        |> delete_files(opts)

      true ->
        changeset
    end
  end

  defp prepare_file(field, opts) do
    case field do
      %Plug.Upload{} ->
        field = Map.put(field, :filename, random_filename(field.filename))
        Map.put(%{}, opts[:field], field)

      _ ->
        %{}
    end
  end

  defp delete_files(changeset, opts) do
    path = apply(opts[:uploader], :url, [{Map.get(changeset.data, opts[:field]), changeset.data}])

    unless is_nil(path) do
      path = path |> String.split("?") |> List.first()
      apply(opts[:uploader], :delete, [{path, changeset.data}])
    end

    changeset
  end

  defp random_filename(filename) do
    "#{SecureRandom.hex(6)}#{Path.extname(filename)}"
  end
end
