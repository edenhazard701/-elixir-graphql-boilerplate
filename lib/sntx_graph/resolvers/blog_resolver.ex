defmodule SntxGraph.BlogResolver do
  import SntxWeb.Payload

  alias Sntx.{Repo, Guardian}
  alias Sntx.Blog.{Post}

  def get_by_text(args, %{context: ctx}) do
    params = %{
      text: args.text,
      author: ctx.user.id
    }

    case Post.get_by_title(params) do
      {:ok, post} -> {:ok, %{post: post}}
    else
      error -> query_error_payload(error)
    end
  end

  def get_list(_, %{context: ctx}) do
    case Post.get_list(ctx.user.id) do
      {:ok, post} -> {:ok, %{post_list: post}}
      error -> query_error_payload(error)
    end
  end

  def create(%{input: input}, %{context: ctx}) do
    params = %{
      title: input.title,
      body: input.body,
      author: ctx.user.id
    }

    case Post.create(params) do
      {:ok, blog_post} -> {:ok, %{blog_post: blog_post}}
      error -> mutation_error_payload(error)
    end
  end

  def update(%{input: input}, %{context: ctx}) do

    case Post.update(input, ctx.user.id) do
      {:ok, blog_post} -> {:ok, %{blog_post: blog_post}}
      error -> mutation_error_payload(error)
    end
  end

  def delete(args, ctx.user.id) do
    case Post.delete(args.post_id, ctx.user.id) do
      {:ok, blog_post} -> {:ok, %{blog_post: blog_post}}
      error -> mutation_error_payload(error)
    end
  end

end
