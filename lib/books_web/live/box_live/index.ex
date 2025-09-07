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
        <:action :let={{_id, box}}>
          <div class="sr-only">
            <.link navigate={~p"/libraries/#{@library_id}/boxes/#{box}"}>Show</.link>
          </div>
          <.link navigate={~p"/libraries/#{@library_id}/boxes/#{box}/edit?return_to=library"}>Edit</.link>
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
        Books without a box
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
    {:ok,
     socket
     |> assign(:page_title, "Listing Boxes")
     |> assign(:library_id, library_id)
     |> stream(:boxes, Boxes.list_boxes(library_id))
     |> stream(:books, Books.list_books(library_id, :nil))}
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

    {:noreply, stream_delete(socket, :books, book)}
  end
end
