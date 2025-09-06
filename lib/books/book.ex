defmodule Books.Book do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true, type: :uuid}
  schema "books" do
    field :name, :string
    field :author, :string
    field :number, :integer
    belongs_to :library, Books.Library, type: :binary_id
    timestamps()
  end

  def changeset(book, attrs) do
    book
    |> cast(attrs, [:name, :author, :number, :library_id])
    |> validate_required([:name, :author, :number, :library_id])
  end
end
