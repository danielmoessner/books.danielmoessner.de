defmodule Books.BoxesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Books.Boxes` context.
  """

  @doc """
  Generate a box.
  """
  def box_fixture(attrs \\ %{}) do
    {:ok, box} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Books.Boxes.create_box()

    box
  end
end
