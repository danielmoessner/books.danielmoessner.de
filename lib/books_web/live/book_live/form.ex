defmodule BooksWeb.BookLive.Form do
  use BooksWeb, :live_view

  alias Books.{Book, Books, Boxes}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="book-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:box_id]} type="select" label="Box" options={@boxes} />
        <.input field={@form[:number]} type="text" label="Number" />
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:author]} type="text" label="Author" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Book</.button>
          <.button navigate={return_path(@return_to, @library_id, @book.box_id, @book.id)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    boxes = Boxes.list_boxes(params["library_id"])
    box_options = Enum.map(boxes, &{&1.name, &1.id})

    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:library_id, params["library_id"])
     |> assign(:book_id, params["book_id"])
     |> assign(:boxes, box_options)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("book"), do: "book"
  defp return_to("box"), do: "box"
  defp return_to("library"), do: "library"
  defp return_to(_), do: "book"

  defp apply_action(socket, :edit, %{"book_id" => id}) do
    book = Books.get_book!(id)

    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Books.change_book(book)))
  end

  defp apply_action(socket, :new, _params) do
    book = %Book{}

    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, book)
    |> assign(:form, to_form(Books.change_book(book)))
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    changeset = Books.change_book(socket.assigns.book, book_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    save_book(socket, socket.assigns.live_action, book_params)
  end

  defp save_book(socket, :edit, book_params) do
    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, socket.assigns.library_id, book.box_id, book.id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_book(socket, :new, book_params) do
    book_params = Map.put(book_params, "library_id", socket.assigns.library_id)

    case Books.create_book(book_params) do
      {:ok, book} ->
        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_navigate(to: return_path("book", socket.assigns.library_id, nil, book))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("book", library_id, _box_id, nil), do: ~p"/libraries/#{library_id}"
  defp return_path("book", library_id, _box_id, book_id), do: ~p"/libraries/#{library_id}/books/#{book_id}"
  defp return_path("box", library_id, nil, _book_id), do: ~p"/libraries/#{library_id}"
  defp return_path("box", library_id, box_id, _book_id), do: ~p"/libraries/#{library_id}/boxes/#{box_id}"
  defp return_path("library", library_id, _box_id, _book_id), do: ~p"/libraries/#{library_id}"
end
