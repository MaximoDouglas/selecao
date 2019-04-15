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
    speeches = for row <- rows do
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
    
    speeches = Enum.drop(speeches, -1)
  end

  def recursive(index, speeches, hour, minutes, end_hour, end_minutes, used_indexes) when (index == length(speeches)) do
    []
  end

  def recursive(index, speeches, hour, minutes, end_hour, end_minutes, used_indexes) do
    if (!(Enum.member?(used_indexes, index))) do
      speech = Enum.at(speeches, index)

      duration =  if(speech.duration != "lightning") do
                                String.to_integer(String.slice(speech.duration, 0..-4))
                              else
                                5
                              end

      m = minutes + duration                        
      
      h = if (m >= 60) do
            hour + 1
          else
            hour
          end

      m = if (m >= 60) do
            m - 60
          else
            m
          end
      
      if (h < end_hour) do
        [index] ++ recursive(index + 1, speeches, h, m, end_hour, end_minutes, used_indexes)
      else
        if (h == end_hour) do
          if (m == end_minutes) do
            [index]
          else
            []
          end
        else
          []
        end
      end
    else
      recursive(index + 1, speeches, hour, minutes, end_hour, end_minutes, used_indexes)
    end
  end
  
  @doc """
  Returns the indexes for the selected speeches in the speeches list to be a part of the session,
  given a period of the day ('morning' or 'afternoon') and a list of speeches

  ## Examples

      iex> get_session()
      [1, 2, 0, ...]
  """
  def get_session_by_interval(begin_intv, end_intv, speeches, used_indexes) do
    splited_time = String.split(begin_intv, ":")
    hour = String.to_integer(Enum.at(splited_time, 0))
    minutes = String.to_integer(Enum.at(splited_time, 1))

    splited_end_time = String.split(end_intv, ":")
    end_hour = String.to_integer(Enum.at(splited_end_time, 0))
    end_minutes = String.to_integer(Enum.at(splited_end_time, 1))

    indexes = []
    indexes = recursive(0, speeches, hour, minutes, end_hour, end_minutes, used_indexes)
  end

  @doc """
  Returns the indexes for the selected speeches in the speeches list to be a part of the session,
  given a period of the day ('morning' or 'afternoon') and a list of speeches

  ## Examples

      iex> get_session()
      [1, 2, 0, ...]
  """
  def get_session(period, speeches, used_indexes) do
    begin_morning = "09:00"
    end_morning = "12:00"

    begin_afternoon = "13:00"
    end_afternoon = "17:00"

    if (period == 0) do
      get_session_by_interval(begin_morning, end_morning, speeches, used_indexes)
    else
      get_session_by_interval(begin_afternoon, end_afternoon, speeches, used_indexes)
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
    file = File.read!("/home/douglas/dev/git/selecao/proposals.txt")
    speeches = file_to_speeches(file)

    period_1 = 0
    period_2 = 1

    used_indexes = []
    
    tracks = []
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

                tracks ++ mount_track(title, session_morning, session_afternoon)
              end
  end

end