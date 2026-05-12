defmodule Books.Repo.Migrations.AddStartNumberToBoxes do
  use Ecto.Migration

  def up do
    alter table(:boxes) do
      add :start_number, :integer, null: false, default: 0
    end

    # Backfill start_number from existing boxed book numbers so current numbering is preserved.
    execute("""
    UPDATE boxes
    SET start_number = COALESCE(
      (SELECT MIN(number) FROM books WHERE books.box_id = boxes.id) - 1,
      0
    )
    """)

    # Normalize boxed book numbers to be contiguous starting at start_number + 1.
    execute("""
    WITH ranked AS (
      SELECT
        b.id AS id,
        bx.start_number + ROW_NUMBER() OVER (PARTITION BY b.box_id ORDER BY b.number) AS new_number
      FROM books b
      JOIN boxes bx ON bx.id = b.box_id
      WHERE b.box_id IS NOT NULL
    )
    UPDATE books
    SET number = (SELECT new_number FROM ranked WHERE ranked.id = books.id)
    WHERE id IN (SELECT id FROM ranked)
    """)
  end

  def down do
    alter table(:boxes) do
      remove :start_number
    end
  end
end
