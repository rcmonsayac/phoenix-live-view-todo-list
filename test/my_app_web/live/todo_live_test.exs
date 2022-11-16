defmodule MyAppWeb.TodoLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest

  test "connected mount", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "<h1>To Do List Live View</h1>"
  end
end
