defmodule Books.Books do
 @moduledoc """
  The Books context.
  """

  import Ecto.Query, warn: false
  alias Books.Repo

  alias Books.Book

  @doc """
  Returns the list of books.

  ## Examples

      iex> list_books()
      [%Book{}, ...]

  """
  def list_books(library_id) do
    Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
  end
  def list_books(library_id, box_id) do
    if box_id == :nil do
      Repo.all(from b in Book, where: b.library_id == ^library_id and is_nil(b.box_id), order_by: b.number)
    else
      Repo.all(from b in Book, where: b.library_id == ^library_id and b.box_id == ^box_id, order_by: b.number)
    end
  end

  @doc """
  Search books by name or author within a library.

  ## Examples

      iex> search_books(library_id, "tolkien")
      [%Book{}, ...]

  """
  def search_books(library_id, search_term) do
    search_pattern = "%#{search_term}%"

    Repo.all(
      from b in Book,
      where: b.library_id == ^library_id and
             (like(b.name, ^search_pattern) or like(b.author, ^search_pattern)),
      order_by: b.number
    )
  end

  @doc """
  Gets a single book.

  Raises `Ecto.NoResultsError` if the Book does not exist.

  ## Examples

      iex> get_book!(123)
      %Book{}

      iex> get_book!(456)
      ** (Ecto.NoResultsError)

  """
  def get_book!(id), do: Repo.get!(Book, id)

  @doc """
  Creates a book.

  ## Examples

      iex> create_book(%{field: value})
      {:ok, %Book{}}

      iex> create_book(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_book(attrs) do
    %Book{}
    |> Book.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a book.

  ## Examples

      iex> update_book(book, %{field: new_value})
      {:ok, %Book{}}

      iex> update_book(book, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_book(%Book{} = book, attrs) do
    book
    |> Book.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a book.

  ## Examples

      iex> delete_book(book)
      {:ok, %Book{}}

      iex> delete_book(book)
      {:error, %Ecto.Changeset{}}

  """
  def delete_book(%Book{} = book) do
    Repo.delete(book)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking book changes.

  ## Examples

      iex> change_book(book)
      %Ecto.Changeset{data: %Book{}}

  """
  def change_book(%Book{} = book, attrs \\ %{}) do
    Book.changeset(book, attrs)
  end

  @doc """
  Get book counts for multiple boxes.

  ## Examples

      iex> get_book_counts_for_boxes([box_id1, box_id2])
      %{box_id1 => 3, box_id2 => 5}

  """
  def get_book_counts_for_boxes(box_ids) when is_list(box_ids) do
    box_ids
    |> Enum.map(fn box_id ->
      count = Repo.aggregate(
        from(b in Book, where: b.box_id == ^box_id),
        :count
      )
      {box_id, count}
    end)
    |> Enum.into(%{})
  end
end
