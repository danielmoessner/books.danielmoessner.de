defmodule Books.Box do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true, type: :uuid}
  schema "boxes" do
    field :name, :string
    belongs_to :library, Books.Library, type: :binary_id

    timestamps()
  end

  def changeset(box, attrs) do
    box
    |> cast(attrs, [:name, :library_id])
    |> validate_required([:name, :library_id])
  end
end
