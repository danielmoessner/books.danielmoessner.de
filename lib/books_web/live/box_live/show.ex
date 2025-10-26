defmodule BooksWeb.BoxLive.Show do
  use BooksWeb, :live_view

  alias Books.Boxes
  alias Books.Books

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@box.name}
        <:subtitle>{@box.id}</:subtitle>
        <:actions>
          <.button navigate={~p"/libraries/#{@library_id}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/libraries/#{@library_id}/boxes/#{@box.id}/edit?return_to=box"}
          >
            <.icon name="hero-pencil-square" /> Edit Box
          </.button>
          <.button
            variant="primary"
            navigate={~p"/libraries/#{@library_id}/books/new?return_to=box"}
          >
            <.icon name="hero-plus" /> Add Book
          </.button>
        </:actions>
      </.header>

      <.book_table
        books={@streams.books}
        library_id={@library_id}
        box_id={@box.id}
        on_delete="delete"
        return_to="box"
        sortable={true}
      />
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"box_id" => id, "library_id" => library_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Box")
     |> assign(:library_id, library_id)
     |> assign(:box, Boxes.get_box!(id))
     |> stream(:books, Books.list_books(library_id, id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:ok, _} = Books.delete_book(book)

    {:noreply, stream_delete(socket, :books, book)}
  end

  @impl true
  def handle_event("reposition", %{"id" => _id, "old" => oldIndex, "new" => newIndex}, socket) do
    books = Books.list_books(socket.assigns.library_id, socket.assigns.box.id)

    min_number = books |> Enum.map(& &1.number) |> Enum.min() || 0
    oldIndexNumber = oldIndex
    newIndexNumber = newIndex
    book_to_move = Enum.at(books, oldIndexNumber)

    books =
      books
      |> Enum.sort_by(& &1.number)
      |> List.delete_at(oldIndexNumber)
      |> List.insert_at(newIndexNumber, book_to_move)
      |> Enum.with_index(min_number)
      |> Enum.map(fn {book, index} ->
        if book.number != index do
          {:ok, _} = Books.update_book(book, %{number: index})
          %{book | number: index}
        else
          book
        end
      end)

    {:noreply, stream(socket, :books, books, reset: true)}
  end
end
