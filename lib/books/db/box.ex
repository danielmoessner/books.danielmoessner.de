defmodule Books.Box do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true, type: :uuid}
  schema "boxes" do
    field :name, :string
    field :start_number, :integer, default: 0
    belongs_to :library, Books.Library, type: :binary_id

    timestamps()
  end

  def changeset(box, attrs) do
    box
    |> cast(attrs, [:name, :start_number, :library_id])
    |> validate_required([:name, :start_number, :library_id])
    |> validate_number(:start_number, greater_than_or_equal_to: 0)
  end
end
