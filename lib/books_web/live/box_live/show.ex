defmodule BooksWeb.BoxLive.Show do
  use BooksWeb, :live_view

  alias Books.Boxes

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@box.name}
        <:subtitle>{@box.id}</:subtitle>
        <:actions>
          <.button navigate={~p"/libraries/#{@library_id}/boxes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/libraries/#{@library_id}/boxes/#{@box}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit box
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@box.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id, "library_id" => library_id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Box")
     |> assign(:library_id, library_id)
     |> assign(:box, Boxes.get_box!(id))}
  end
end
