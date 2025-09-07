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
end
