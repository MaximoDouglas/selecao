defmodule ConferenceWeb.PageController do
  use ConferenceWeb, :controller

  alias Conference.Management

  def index(conn, _params) do
    tracks = Management.get_tracks("/home/douglas/dev/git/selecao/proposals.txt")
    render(conn, "index.html", tracks: tracks)
  end
end
