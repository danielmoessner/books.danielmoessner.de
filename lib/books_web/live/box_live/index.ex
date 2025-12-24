defmodule BooksWeb.BoxLive.Index do
  use BooksWeb, :live_view

  alias Books.Boxes
  alias Books.Books

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Boxes
        <:actions>
          <.button variant="primary" navigate={~p"/libraries/#{@library_id}/boxes/new"}>
            <.icon name="hero-plus" /> New Box
          </.button>
        </:actions>
      </.header>

      <.table
        id="boxes"
        rows={@streams.boxes}
        row_click={fn {_id, box} -> JS.navigate(~p"/libraries/#{@library_id}/boxes/#{box}") end}
      >
        <:col :let={{_id, box}} label="Name">{box.name}</:col>
        <:col :let={{_id, box}} label="Books">{Map.get(@book_counts, box.id, 0)}</:col>
        <:action :let={{_id, box}}>
          <div class="sr-only">
            <.link navigate={~p"/libraries/#{@library_id}/boxes/#{box}"}>Show</.link>
          </div>
          <.link navigate={~p"/libraries/#{@library_id}/boxes/#{box}/edit?return_to=library"}>
            Edit
          </.link>
        </:action>
        <:action :let={{id, box}}>
          <.link
            phx-click={JS.push("delete", value: %{id: box.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>

      <div class="my-16"></div>
      <.header>
        Books
        <form id="search-form" phx-debounce="300" phx-change="search" phx-submit="noop">
          <.input
            type="search"
            id="search"
            name="search"
            value={@search}
            placeholder="Search books..."
            class="input min-w-sm"
          />
        </form>
        <:actions>
          <.button variant="primary" navigate={~p"/libraries/#{@library_id}/books/new"}>
            <.icon name="hero-plus" /> New Book
          </.button>
        </:actions>
      </.header>
      <.book_table
        books={@streams.books}
        library_id={@library_id}
        on_delete="delete_book"
        return_to="library"
      />
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"library_id" => library_id}, _session, socket) do
    boxes = Boxes.list_boxes(library_id)
    box_ids = Enum.map(boxes, & &1.id)
    book_counts = Books.get_book_counts_for_boxes(box_ids)

    {:ok,
     socket
     |> assign(:page_title, "Listing Boxes")
     |> assign(:library_id, library_id)
     |> assign(:search, "")
     |> assign(:book_counts, book_counts)
     |> stream(:boxes, boxes)
     |> stream(:books, Books.list_books(library_id))}
  end

  @impl true
  def handle_event("search", %{"search" => search_term}, socket) do
    library_id = socket.assigns.library_id

    filtered_books =
      if search_term == "" do
        Books.list_books(library_id)
      else
        Books.search_books(library_id, search_term)
      end

    {:noreply,
     socket
     |> assign(:search, search_term)
     |> stream(:books, filtered_books, reset: true)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    box = Boxes.get_box!(id)
    {:ok, _} = Boxes.delete_box(box)

    {:noreply, stream_delete(socket, :boxes, box)}
  end

  @impl true
  def handle_event("delete_book", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:ok, _} = Books.delete_book(book)

    # Update book counts if the deleted book was in a box
    updated_book_counts = if book.box_id do
      current_count = Map.get(socket.assigns.book_counts, book.box_id, 0)
      Map.put(socket.assigns.book_counts, book.box_id, max(0, current_count - 1))
    else
      socket.assigns.book_counts
    end

    {:noreply,
     socket
     |> assign(:book_counts, updated_book_counts)
     |> stream_delete(:books, book)}
  end

  @impl true
  def handle_event("noop", _params, socket), do: {:noreply, socket}
end
