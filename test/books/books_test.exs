defmodule Books.BooksTest do
  use Books.DataCase

  alias Books.Books, as: BooksContext
  alias Books.Repo

  describe "books" do
    test "update_book/2 persists number changes" do
      library = Repo.insert!(%Books.Library{})
      box = Repo.insert!(%Books.Box{name: "box", library_id: library.id, start_number: 0})

      {:ok, book} =
        BooksContext.create_book(%{
          "name" => "Some Book",
          "author" => "Some Author",
          "library_id" => library.id,
          "box_id" => box.id
        })

      assert {:ok, updated} = BooksContext.update_book(book, %{number: 42})
      assert updated.number == 42

      reloaded = BooksContext.get_book!(book.id)
      assert reloaded.number == 42
    end
  end
end
