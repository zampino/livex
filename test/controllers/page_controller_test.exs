defmodule Livex.PageControllerTest do
  use Livex.ConnCase

  alias Livex.Page
  @valid_attrs %{}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing pages"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, page_path(conn, :new)
    assert html_response(conn, 200) =~ "New page"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, page_path(conn, :create), page: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :index)
    assert Repo.get_by(Page, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, page_path(conn, :create), page: @invalid_attrs
    assert html_response(conn, 200) =~ "New page"
  end

  test "shows chosen resource", %{conn: conn} do
    page = Repo.insert! %Page{}
    conn = get conn, page_path(conn, :show, page)
    assert html_response(conn, 200) =~ "Show page"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, page_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    page = Repo.insert! %Page{}
    conn = get conn, page_path(conn, :edit, page)
    assert html_response(conn, 200) =~ "Edit page"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    page = Repo.insert! %Page{}
    conn = put conn, page_path(conn, :update, page), page: @valid_attrs
    assert redirected_to(conn) == page_path(conn, :show, page)
    assert Repo.get_by(Page, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    page = Repo.insert! %Page{}
    conn = put conn, page_path(conn, :update, page), page: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit page"
  end

  test "deletes chosen resource", %{conn: conn} do
    page = Repo.insert! %Page{}
    conn = delete conn, page_path(conn, :delete, page)
    assert redirected_to(conn) == page_path(conn, :index)
    refute Repo.get(Page, page.id)
  end
end
