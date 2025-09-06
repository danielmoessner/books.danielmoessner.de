defmodule BooksWeb.BooksLive do
  use BooksWeb, :live_view
  alias Books.{Repo, Book, Library}
  import Ecto.Query

  def mount(%{"library_id" => library_id}, _session, socket) do
    # Ensure library exists
    library = Repo.get(Library, library_id)
    if is_nil(library) do
      Repo.insert!(%Library{id: library_id})
    end

    {:ok, assign(socket,
      library_id: library_id,
      query: "",
      books: list_books(library_id, ""),
      edit_book: nil,
      changeset: nil
    )}
  end

  def handle_event("search", %{"query" => query}, socket) do
    {:noreply, assign(socket, query: query, books: list_books(socket.assigns.library_id, query))}
  end

  def handle_event("create_book", %{"name" => name, "author" => author, "number" => number}, socket) do
    attrs = %{name: name, author: author, number: String.to_integer(number), library_id: socket.assigns.library_id}
    case Repo.insert(Book.changeset(%Book{}, attrs)) do
      {:ok, _book} ->
        {:noreply, assign(socket,
          books: list_books(socket.assigns.library_id, socket.assigns.query),
          changeset: nil
        )}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("delete_book", %{"id" => id}, socket) do
    book = Repo.get!(Book, id)
    Repo.delete!(book)
    {:noreply, assign(socket, books: list_books(socket.assigns.library_id, socket.assigns.query))}
  end

  def handle_event("edit_book", %{"id" => id}, socket) do
    book = Repo.get!(Book, id)
    {:noreply, assign(socket, edit_book: book)}
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply, assign(socket, edit_book: nil)}
  end

  def handle_event("update_book", %{"id" => id, "name" => name, "author" => author, "number" => number}, socket) do
    book = Repo.get!(Book, id)
    attrs = %{name: name, author: author, number: String.to_integer(number)}
    case Repo.update(Book.changeset(book, attrs)) do
      {:ok, _book} ->
        {:noreply, assign(socket,
          books: list_books(socket.assigns.library_id, socket.assigns.query),
          edit_book: nil,
          changeset: nil
        )}
      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <h1 class="text-3xl font-bold text-orange-600 mb-6">Books</h1>

      <form phx-submit="create_book" class="mb-8 bg-base-200 p-6 rounded-lg shadow">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <%!-- deploy again --%>
          <input
            name="name"
            type="text"
            placeholder="Book name"
            class="input input-bordered w-full"
            required
          />
          <input
            name="author"
            type="text"
            placeholder="Author"
            class="input input-bordered w-full"
            required
          />
          <input
            name="number"
            type="number"
            placeholder="Number"
            class="input input-bordered w-full"
            required
          />
          <button type="submit" class="btn bg-orange-500 text-white hover:bg-orange-600 w-full">
            Add Book
          </button>
        </div>

        <%= if @changeset do %>
          <div class="mt-4 text-red-600">
            <%= for {field, {message, _}} <- @changeset.errors do %>
              <p><%= field %>: <%= message %></p>
            <% end %>
          </div>
        <% end %>
      </form>

      <form phx-change="search" phx-debounce="300" class="mb-6">
        <input
          type="text"
          name="query"
          value={@query}
          placeholder="Search books..."
          class="input input-bordered w-full max-w-xs"
        />
      </form>

      <div class="bg-white rounded-lg shadow overflow-hidden">
        <%= if @edit_book do %>
          <div class="p-4 bg-yellow-50 border-b">
            <h3 class="text-lg font-semibold mb-4">Edit Book</h3>
            <form phx-submit="update_book" class="grid grid-cols-1 md:grid-cols-4 gap-4">
              <input type="hidden" value={@edit_book.id} />
              <input
                name="name"
                type="text"
                value={@edit_book.name}
                class="input input-bordered w-full"
                required
              />
              <input
                name="author"
                type="text"
                value={@edit_book.author}
                class="input input-bordered w-full"
                required
              />
              <input
                name="number"
                type="number"
                value={@edit_book.number}
                class="input input-bordered w-full"
                required
              />
              <div class="flex gap-2">
                <button type="submit" class="btn btn-success flex-1">Update</button>
                <button type="button" phx-click="cancel_edit" class="btn btn-outline flex-1">Cancel</button>
              </div>
            </form>
          </div>
        <% end %>

        <ul class="divide-y divide-gray-200">
          <%= for book <- @books do %>
            <li class="p-4 flex justify-between items-center">
              <div>
                <strong><%= book.number %></strong> - <%= book.author %> - <%= book.name %>
              </div>
              <div class="flex gap-2">
                <button
                  phx-click="edit_book"
                  phx-value-id={book.id}
                  class="btn btn-sm btn-outline"
                >
                  Edit
                </button>
                <button
                  phx-click="delete_book"
                  phx-value-id={book.id}
                  data-confirm="Are you sure?"
                  class="btn btn-sm btn-error"
                >
                  Delete
                </button>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  defp list_books(library_id, "") do
    Repo.all(from b in Book, where: b.library_id == ^library_id, order_by: b.number)
  end
  defp list_books(library_id, query) do
    Repo.all(from b in Book, where: b.library_id == ^library_id and (like(b.name, ^"%#{query}%") or like(b.author, ^"%#{query}%")), order_by: b.number)
  end
end
