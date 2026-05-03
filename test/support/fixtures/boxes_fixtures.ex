defmodule Books.BoxesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Books.Boxes` context.
  """

  @doc """
  Generate a box.
  """
  def box_fixture(attrs \\ %{}) do
    library_id =
      Map.get(attrs, :library_id) ||
        Map.get(attrs, "library_id") ||
        Books.Repo.insert!(%Books.Library{}).id

    {:ok, box} =
      attrs
      |> Enum.into(%{
        name: "some name",
        library_id: library_id
      })
      |> Books.Boxes.create_box()

    box
  end
end
