defmodule ConferenceWeb.PageController do
  use ConferenceWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
