defmodule BooksWeb.BookLive do
  use BooksWeb, :live_view
  alias Books.{Repo, Book}
  import Ecto.Query

  def render(assigns) do
    ~H"""
    <form phx-change="search" phx-debounce="300">
      <input type="text" name="query" value={@query} placeholder="Search books..." class="input input-bordered w-full max-w-xs" />
    </form>

    <ul>
      <%= for book <- @books do %>
        <li>
          <strong><%= book.number %></strong> - <%= book.author %> - <%= book.name %>
        </li>
      <% end %>
    </ul>
    """
  end

  def mount(%{"library_id" => library_id}, _session, socket) do
    {:ok, assign(socket, query: "", library_id: library_id, books: list_books(library_id, ""))}
  end

  def handle_event("search", %{"query" => query}, socket) do
    IO.inspect(query, label: "Search Query")
    {:noreply, assign(socket, query: query, books: list_books(socket.assigns.library_id, query))}
  end

  defp list_books(library_id, "") do
    Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
  end
  defp list_books(library_id, query) do
    Repo.all(from b in Book, where: b.library_id == ^library_id and (like(b.name, ^"%#{query}%") or like(b.author, ^"%#{query}%")), order_by: b.number)
  end
end
