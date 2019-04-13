defmodule Conference.Management do
  @moduledoc """
  The Management context.
  """

  import Ecto.Query, warn: false

  @doc """
  Returns the list of speeches on the file.

  ## Examples

      iex> get_speeches()
      [%{title: speech_name, duration: speech_duration}, ...]

  """
  def get_speeches do
    file = File.read!("/home/douglas/dev/git/selecao/proposals.txt")
    rows =  String.split(file, "\n")
    
    speeches = []
    for row <- rows do
      words = String.split(row, " ")
      speech_duration = List.last(words)
      
      words = List.delete_at(words, length(words) - 1)

      speech_words = ""
      speech_name = for word <- words do
                      speech_words <> " " <> word
                    end
      
      speech = %{title: speech_name, duration: speech_duration}
      speeches ++ speech
    end
  end

end