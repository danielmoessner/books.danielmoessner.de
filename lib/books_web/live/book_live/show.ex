defmodule BooksWeb.BookLive.Show do
  use BooksWeb, :live_view

  alias Books.Books

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@book.number} - {@book.name}
        <:subtitle>by {@book.author}</:subtitle>
        <:actions>
          <.button navigate={if @book.box_id, do: ~p"/libraries/#{@library_id}/boxes/#{@book.box_id}", else: ~p"/libraries/#{@library_id}"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/libraries/#{@library_id}/books/#{@book.id}/edit?return_to=book"}
          >
            <.icon name="hero-pencil-square" /> Edit book
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Number">{@book.number}</:item>
        <:item title="Name">{@book.name}</:item>
        <:item title="Author">{@book.author}</:item>
      </.list>

    </Layouts.app>
    """
  end

  @impl true
  @spec mount(map(), any(), map()) :: {:ok, map()}
  def mount(%{"book_id" => id, "library_id" => library_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Book")
     |> assign(:library_id, library_id)
     |> assign(:book, Books.get_book!(id))}
  end
end
