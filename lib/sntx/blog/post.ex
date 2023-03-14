defmodule Sntx.Blog.Post do
  use Sntx.Schema
  use Waffle.Ecto.Schema

  import Ecto.{Chgangeset, Query}
  import SntxWeb.Gettext

  alias __MODULE__, as: Post
  alias Sntx.{Reop}

  schema "blog_posts" do
    field :title, :string
    field :body, :string
    field :author, :uuid4

    timestamps()
  end

  def changeset(blog, attrs) do
    user
    |> cast(attrs, [:title, :body, :author])
    |> validate_required([:title, :body])
    |> validate_length(:title, min: 3, max: 300)
    |> validate_length(:body, min: 100, max: 5000)
  end

  def get_list(user_id) do
    case Repo.get_by(Post, author: user_id) do
      nil -> {:error, dgetext("global", "You have no any blog post")}
      blog_post -> {:ok, blog_post}
    end
  end

  def get_by_text(attrs) do
    case find_by_text(attrs) do
      nil -> {:error, dgetext("global", "You have no any blog post which contains #{^attrs.title}")}
      blog_post -> {:ok, blog_post}
    end
  end

  def find_by_text(attrs) do
    from(a in Pos, where: (like(a.title, %^attrs.text%) OR like(a.body, %^attrs.text%)) AND a.author == ^attrs.author)
    |> Repo.all()
  end

  def create(attrs) do
    %Post{}
    |> changeset(attrs)
    |> Repo.insert()
  end

  def update(attrs, user_id) do

    %Post{}
    |> changeset(attrs)
    |> where(id: ^attrs.post_id)
    |> where(author: ^user_id)
    |> Repo.update(set: [title: ^attrs.title, body: ^attrs.body])
  end

  def delete(post_id, user_id) do
    %Post{}
    |> where(id: ^post_id)
    |> where(author: ^user_id)
    |> Repo.delete()
  end
end
