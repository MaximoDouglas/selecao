defmodule ConferenceWeb.TrackControllerTest do
  use ConferenceWeb.ConnCase

  alias Conference.Management

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:track) do
    {:ok, track} = Management.create_track(@create_attrs)
    track
  end

  describe "index" do
    test "lists all tracks", %{conn: conn} do
      conn = get conn, track_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Tracks"
    end
  end

  describe "new track" do
    test "renders form", %{conn: conn} do
      conn = get conn, track_path(conn, :new)
      assert html_response(conn, 200) =~ "New Track"
    end
  end

  describe "create track" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, track_path(conn, :create), track: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == track_path(conn, :show, id)

      conn = get conn, track_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Track"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, track_path(conn, :create), track: @invalid_attrs
      assert html_response(conn, 200) =~ "New Track"
    end
  end

  describe "edit track" do
    setup [:create_track]

    test "renders form for editing chosen track", %{conn: conn, track: track} do
      conn = get conn, track_path(conn, :edit, track)
      assert html_response(conn, 200) =~ "Edit Track"
    end
  end

  describe "update track" do
    setup [:create_track]

    test "redirects when data is valid", %{conn: conn, track: track} do
      conn = put conn, track_path(conn, :update, track), track: @update_attrs
      assert redirected_to(conn) == track_path(conn, :show, track)

      conn = get conn, track_path(conn, :show, track)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, track: track} do
      conn = put conn, track_path(conn, :update, track), track: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Track"
    end
  end

  describe "delete track" do
    setup [:create_track]

    test "deletes chosen track", %{conn: conn, track: track} do
      conn = delete conn, track_path(conn, :delete, track)
      assert redirected_to(conn) == track_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, track_path(conn, :show, track)
      end
    end
  end

  defp create_track(_) do
    track = fixture(:track)
    {:ok, track: track}
  end
end
