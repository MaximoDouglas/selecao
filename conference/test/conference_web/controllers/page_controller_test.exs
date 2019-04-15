defmodule ConferenceWeb.PageControllerTest do
  use ConferenceWeb.ConnCase

  @doc """
    author: MaximoDouglas
  """
  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert get_resp_header(conn, "content-type") == ["text/html; charset=utf-8"]
  end
end
