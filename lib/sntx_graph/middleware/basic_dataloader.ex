defmodule SntxGraph.Middleware.BasicDataloader do
  import Ecto.Query

  def data do
    Dataloader.Ecto.new(Sntx.Repo, query: &query/2)
  end

  defp query(queryable, _) do
    from u in queryable, order_by: [asc: :inserted_at]
  end
end
