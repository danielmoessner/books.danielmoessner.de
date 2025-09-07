defmodule BooksWeb.Router do
  use BooksWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BooksWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BooksWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/libraries/:library_id", BoxLive.Index, :index

    live "/libraries/:library_id/books/new", BookLive.Form, :new
    live "/libraries/:library_id/books/:book_id", BookLive.Show, :show
    live "/libraries/:library_id/books/:book_id/edit", BookLive.Form, :edit

    live "/libraries/:library_id/boxes/new", BoxLive.Form, :new
    live "/libraries/:library_id/boxes/:box_id", BoxLive.Show, :show
    live "/libraries/:library_id/boxes/:box_id/edit", BoxLive.Form, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", BooksWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:books, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BooksWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
