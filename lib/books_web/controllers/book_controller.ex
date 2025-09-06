defmodule BooksWeb.BookController do
  use BooksWeb, :controller

  alias Books.Book
  alias Books.Library
  alias Books.Repo
  import Ecto.Query

  def index(conn, %{"library_id" => library_id}) do
    library_uuids = Repo.all(from l in Library, select: l.id)
    IO.inspect(library_uuids, label: "All Library UUIDs")
    books = Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
    render(conn, :index, books: books, library_id: library_id, edit_book: nil)
  end

  def create(conn, %{"library_id" => library_id, "name" => name, "author" => author, "number" => number}) do
    attrs = %{name: name, author: author, number: String.to_integer(number), library_id: library_id}
    case Repo.insert(Book.changeset(%Book{}, attrs)) do
      {:ok, _book} ->
        redirect(conn, to: ~p"/libraries/#{library_id}/books")
      {:error, changeset} ->
        books = Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
        render(conn, :index, books: books, library_id: library_id, changeset: changeset, edit_book: nil)
    end
  end

  def delete(conn, %{"library_id" => library_id, "id" => id}) do
    book = Repo.get!(Book, id)
    Repo.delete!(book)
    redirect(conn, to: ~p"/libraries/#{library_id}/books")
  end

  def edit(conn, %{"library_id" => library_id, "id" => id}) do
    book = Repo.get!(Book, id)
    books = Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
    render(conn, :index, books: books, library_id: library_id, edit_book: book)
  end

  def update(conn, %{"library_id" => library_id, "id" => id, "name" => name, "author" => author, "number" => number}) do
    book = Repo.get!(Book, id)
    attrs = %{name: name, author: author, number: String.to_integer(number)}
    case Repo.update(Book.changeset(book, attrs)) do
      {:ok, _book} ->
        redirect(conn, to: ~p"/libraries/#{library_id}/books")
      {:error, changeset} ->
        books = Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
        render(conn, :index, books: books, library_id: library_id, edit_book: book, changeset: changeset)
    end
  end
end
