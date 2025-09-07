defmodule Books.Repo.Migrations.AddBoxId do
  use Ecto.Migration

  def change do
    alter table(:books) do
      add :box_id, references(:boxes, type: :binary_id), null: true
    end
  end
end
