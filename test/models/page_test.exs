defmodule Livex.PageTest do
  use Livex.ModelCase

  alias Livex.Page

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Page.changeset(%Page{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Page.changeset(%Page{}, @invalid_attrs)
    refute changeset.valid?
  end
end
