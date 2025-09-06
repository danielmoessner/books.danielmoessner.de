defmodule BooksWeb.PageController do
  use BooksWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
