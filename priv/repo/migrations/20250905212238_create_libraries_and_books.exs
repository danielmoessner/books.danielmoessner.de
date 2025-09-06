defmodule Books.Repo.Migrations.CreateLibrariesAndBooks do
  use Ecto.Migration

  def change do
    create table(:libraries, primary_key: false) do
      add :id, :binary_id, primary_key: true
      timestamps()
    end

    create table(:books, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :author, :string, null: false
      add :number, :integer, null: false
      add :library_id, references(:libraries, type: :binary_id, on_delete: :delete_all), null: false
      timestamps()
    end

    create index(:books, [:library_id])
  end
end
