defmodule Conference.Management do
  @moduledoc """
  The Management context.
  """

  @doc """
  Returns the list of speeches on the file.

  ## Examples

      iex> get_speeches()
      [%{title: speech_name, duration: speech_duration}, ...]

  """
  def file_to_speeches(file) do
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

  @doc """
  Returns the indexes for the selected speeches in the speeches list to be a part of the session,
  given a period of the day ('morning' or 'afternoon') and a list of speeches

  ## Examples

      iex> get_session()
      [1, 2, 0, ...]
  """
  def get_session(period, speeches, used_indexes) do
    indexes = []
    indexes = if (period == 0) do
                indexes ++ [0, 1, 2]
              else
                indexes ++ [3, 4, 5]
              end
  end

  @doc """
  Returns the indexes for the selected speeches in the speeches list to be a part of the session,
  given a period of the day ('morning' or 'afternoon') and a list of speeches

  ## Examples

      iex> get_session()
      [1, 2, 0, ...]
  """
  def mount_track(title, session_morning, session_afternoon) do
    
    events = []
    events = events ++ session_morning

    events = events ++ [%{title: "Almoço", duration: " "}]

    events = events ++ session_afternoon

    events = events ++ [%{title: "Evento de Networking", duration: " "}]
    
    track = %{title: title, events: events, size: length(session_morning ++ session_afternoon) + 2}
  end

  @doc """
  Returns the list of tracks

  ## Examples

      iex> get_tracks()
      [%{title: track_name, events: [{title: event_title, duration: event_duration}, ...]}, ...]

  """
  def get_tracks do
    speeches = File.read!("/home/douglas/dev/git/selecao/proposals.txt")
    |> file_to_speeches()

    period_1 = 0
    period_2 = 1

    used_indexes = []
    
    tracks =  for k <- 0..1 do
                indexes_morning = get_session(period_1, speeches, used_indexes)
                used_indexes = used_indexes ++ indexes_morning

                session_morning = []
                session_morning = for i <- indexes_morning do
                                    session_morning ++ Enum.at(speeches, i)
                                  end
                
                indexes_afternoon = get_session(period_2, speeches, used_indexes)
                used_indexes = used_indexes ++ indexes_afternoon

                session_afternoon = []
                session_afternoon = for j <- indexes_afternoon do
                                      session_afternoon ++ Enum.at(speeches, j)
                                    end
                
                title = if (k == 0) do
                          "Track A"
                        else
                          "Track B"
                        end

                mount_track(title, session_morning, session_afternoon)
              end
  end

end