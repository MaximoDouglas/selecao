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
    rows =  String.split(file, "\n")
    
    for row <- rows do
      words = String.split(row, " ")

      if (List.last(words) == "lightning") do
        words = List.delete_at(words, length(words) - 1)
        words ++ "5min"
      else
        words
      end
    end
  end

end