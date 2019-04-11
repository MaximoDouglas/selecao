defmodule ConferenceWeb.PageController do
  use ConferenceWeb, :controller

  alias Conference.Management

  def index(conn, _params) do
    speeches = Management.get_rows()
    render(conn, "index.html", speeches: speeches)
  end
end
