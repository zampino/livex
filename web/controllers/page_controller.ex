defmodule Livex.PageController do
  use Livex.Web, :controller

  alias Livex.Page

  def index(conn, _params) do
    render(conn, "index.html", pages: [])
  end
end
