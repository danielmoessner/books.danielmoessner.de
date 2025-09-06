defmodule Books.Library do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true, type: :uuid}
  schema "libraries" do
    timestamps()
  end

  def changeset(library, attrs) do
    library
    |> cast(attrs, [])
    |> validate_required([])
  end
end
