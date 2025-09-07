defmodule Books.Boxes do
  @moduledoc """
  The Boxes context.
  """

  import Ecto.Query, warn: false
  alias Books.Repo

  alias Books.Box

  @doc """
  Returns the list of boxes.

  ## Examples

      iex> list_boxes()
      [%Box{}, ...]

  """
  def list_boxes(library_id) do
    Repo.all(from b in Box, where: b.library_id == ^library_id)
  end

  @doc """
  Gets a single box.

  Raises `Ecto.NoResultsError` if the Box does not exist.

  ## Examples

      iex> get_box!(123)
      %Box{}

      iex> get_box!(456)
      ** (Ecto.NoResultsError)

  """
  def get_box!(id), do: Repo.get!(Box, id)

  @doc """
  Creates a box.

  ## Examples

      iex> create_box(%{field: value})
      {:ok, %Box{}}

      iex> create_box(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_box(attrs) do
    %Box{}
    |> Box.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a box.

  ## Examples

      iex> update_box(box, %{field: new_value})
      {:ok, %Box{}}

      iex> update_box(box, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_box(%Box{} = box, attrs) do
    box
    |> Box.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a box.

  ## Examples

      iex> delete_box(box)
      {:ok, %Box{}}

      iex> delete_box(box)
      {:error, %Ecto.Changeset{}}

  """
  def delete_box(%Box{} = box) do
    Repo.delete(box)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking box changes.

  ## Examples

      iex> change_box(box)
      %Ecto.Changeset{data: %Box{}}

  """
  def change_box(%Box{} = box, attrs \\ %{}) do
    Box.changeset(box, attrs)
  end
end
