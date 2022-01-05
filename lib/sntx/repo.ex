defmodule Sntx.Repo do
  use Ecto.Repo,
    otp_app: :sntx,
    adapter: Ecto.Adapters.Postgres

  import Ecto.Query

  def filter(query, _, nil), do: query

  def filter(query, col, list) when is_list(list) do
    list = list |> Enum.reject(&(is_nil(&1) or &1 == ""))

    if length(list) > 0 do
      from(r in query, where: field(r, ^col) in ^list)
    else
      query
    end
  end

  def filter(query, col, val) do
    from(r in query, where: field(r, ^col) == ^val)
  end

  def order(query, args) do
    order = prepare_sort_order(args[:sort_order])
    column = prepare_sort_by(args[:sort_by])

    order_by(query, [t], [{^order, field(t, ^column)}])
  end

  def paginate(query, offset \\ 0, limit \\ 15) do
    if limit == -1 do
      query
    else
      from(r in query, offset: ^offset, limit: ^limit)
    end
  end

  def search(query, _, nil), do: query
  def search(query, nil, _), do: query

  def search(query, columns, terms) do
    dyn =
      Enum.reduce(columns, dynamic(true), fn col, acc_query ->
        dynamic([r], ilike(field(r, ^col), ^"\%#{terms}%") or ^acc_query)
      end)

    from query, where: ^dyn
  end

  def search_ft(query, nil), do: query

  # TODO: order by ts_rank_cd
  def search_ft(query, terms) do
    query
    |> where(
      [q],
      fragment("? @@ websearch_to_tsquery('english', ?)", q.searchable, ^terms)
    )
  end

  def select(query, col) do
    from(r in query, select: field(r, ^col))
  end

  defp prepare_sort_by(nil), do: :inserted_at

  defp prepare_sort_by(sort_by) do
    sort_by
    |> Macro.underscore()
    |> String.to_atom()
  end

  defp prepare_sort_order(nil), do: :asc_nulls_last

  defp prepare_sort_order(order) do
    "#{order}_nulls_last"
    |> Macro.underscore()
    |> String.to_atom()
  end
end
