defmodule Conference.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false

  @doc """
  Returns the list of tracks on the file.

  ## Examples

      iex> list_tracks()
      [%Track{}, ...]

  """
  def get_rows do
    file = File.read!("/home/douglas/dev/git/selecao/proposals.txt")
    rows = String.split(file, "\n")

    list = []

    for speech <- rows do
      list ++ speech
    end
  end

end