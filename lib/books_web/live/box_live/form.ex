defmodule BooksWeb.BoxLive.Form do
  use BooksWeb, :live_view

  alias Books.Boxes
  alias Books.Box

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage box records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="box-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Box</.button>
          <.button navigate={return_path("library", @box.id, @library_id)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:library_id, params["library_id"])
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("box"), do: "box"
  defp return_to("library"), do: "library"
  defp return_to(_), do: "box"

  defp apply_action(socket, :edit, %{"box_id" => id}) do
    box = Boxes.get_box!(id)

    socket
    |> assign(:page_title, "Edit Box")
    |> assign(:box, box)
    |> assign(:form, to_form(Boxes.change_box(box)))
  end

  defp apply_action(socket, :new, _params) do
    box = %Box{}

    socket
    |> assign(:page_title, "New Box")
    |> assign(:box, box)
    |> assign(:form, to_form(Boxes.change_box(box)))
  end

  @impl true
  def handle_event("validate", %{"box" => box_params}, socket) do
    changeset = Boxes.change_box(socket.assigns.box, box_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"box" => box_params}, socket) do
    save_box(socket, socket.assigns.live_action, box_params)
  end

  defp save_box(socket, :edit, box_params) do
    case Boxes.update_box(socket.assigns.box, box_params) do
      {:ok, box} ->
        {:noreply,
         socket
         |> put_flash(:info, "Box updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, box, socket.assigns.library_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_box(socket, :new, box_params) do
    box_params_with_library = Map.put(box_params, "library_id", socket.assigns.library_id)

    case Boxes.create_box(box_params_with_library) do
      {:ok, box} ->
        {:noreply,
         socket
         |> put_flash(:info, "Box created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, box, socket.assigns.library_id))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("library", _box, library_id), do: ~p"/libraries/#{library_id}"
  defp return_path("box", box, library_id), do: ~p"/libraries/#{library_id}/boxes/#{box}"
end
