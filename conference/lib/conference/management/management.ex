defmodule Conference.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false
  alias Conference.Repo

  alias Conference.Management.Track

  @doc """
  Returns the list of tracks on the file.

  ## Examples

      iex> list_tracks()
      [%Track{}, ...]

  """
  def get_rows do
    file = File.read!("/home/douglas/dev/git/selecao/proposals.txt")
    rows = String.split(file, "\n")

    list_t = []
    counter = 0

    for row <- rows do
      list_t ++ %Track{id: counter, name: row}
    end
  end