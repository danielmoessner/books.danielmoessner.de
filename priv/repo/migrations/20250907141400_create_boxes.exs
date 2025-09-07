defmodule Books.Repo.Migrations.CreateBoxes do
  use Ecto.Migration

  def change do
    create table(:boxes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :library_id, references(:libraries, type: :binary_id, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
