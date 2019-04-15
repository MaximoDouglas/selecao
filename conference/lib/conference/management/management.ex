defmodule Conference.Management do
  @moduledoc """
  The Management context.
  """

  @doc """
  Returns the list of speeches on the file, using its path as input.
  Speech struct = {title: <speech_name>, duration: <speech_duration>}
  
  ##  In: 
        file: File path
      Out:
        List of speeches in the file
  """
  def file_to_speeches(file) do
    rows = file
    |> String.split("\n")
    
    speeches = []
    for row <- rows do
      words = row
      |> String.split(" ")

      speech_duration = words
      |> List.last()
      
      words = words
      |> List.delete_at(length(words) - 1)

      speech_words = ""
      speech_name = for word <- words do
                      speech_words <> " " <> word
                    end
      
      speech = %{title: speech_name, duration: speech_duration}
      speeches ++ speech
    end
    |> Enum.drop(-1)
  end
  
  @doc """
  Returns a list with two values, that represents, respectively, hour and minutes after adding the given speech

  ##  In: 
        speech: speech that will be added to some list
        hour: integer representing the hour before adding the speech
        minutes: integer representing the minutes before adding the speech
      Out:
        List:
          0: Hour -> integer representing the hour after adding the speech
          1: Minutes -> integer representing the minutes after adding the speech
  """  
  def hour_and_minutes(speech, hour, minutes) do
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
    [h] ++ [m]
  end

  @doc """
  Recursive function that gets speeches still available

  ##  In: 
        index: integer to get a speech in the list os speeches
        speeches: list of speeches
        hour: incremented hour (it begins as 09 for morning sessions and 13 for afternoon sessions)
        minutes: incremented minutes
        end_hour: limit hour (12 for morning sessions and 17 for afternoon sessions)
        end_minutes: limit minutes
        used_indexes: indexes of the speeches that are already in use
      Out:
        [index]: which is a list containing just the index of the speech (in the list of 
        speeches) if it is available and do not passes the limit hour when added to the session.
  """
  def recursive(index, speeches, hour, minutes, end_hour, end_minutes, used_indexes) do
    if (index < length(speeches)) do
      if (!(Enum.member?(used_indexes, index))) do
        speech = Enum.at(speeches, index)

        h = Enum.at(hour_and_minutes(speech, hour, minutes), 0)
        m = Enum.at(hour_and_minutes(speech, hour, minutes), 1)
        
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
    else
      []
    end
  end
  
  @doc """
  Returns the indexes for the selected speeches in the speeches list to be a part of the session,
  given a interval of time, a list of speeches and a list of indexes of speeches.

  ##  In: 
        begin_intv: Time in the format "hh:mm"
        end_intv: Time in the format "hh:mm"
        speeches: List of speeches
        used_indexes: indexes of the speeches that are already in use
      Out:
        recursive: which uses recursivity to mount the session for the given interval of time
  """
  def get_session_by_interval(begin_intv, end_intv, speeches, used_indexes) do
    splited_time = String.split(begin_intv, ":")
    hour = String.to_integer(Enum.at(splited_time, 0))
    minutes = String.to_integer(Enum.at(splited_time, 1))

    splited_end_time = String.split(end_intv, ":")
    end_hour = String.to_integer(Enum.at(splited_end_time, 0))
    end_minutes = String.to_integer(Enum.at(splited_end_time, 1))

    recursive(0, speeches, hour, minutes, end_hour, end_minutes, used_indexes)
  end

  @doc """
  Returns the indexes for the selected speeches in the speeches list to be a part of the session,
  given a period of the day, a list of speeches and a list of indexes of speeches.

  ##  In: 
        period:
          0: morning session
          1: afternoon session
        speeches: List of speeches
        used_indexes: indexes of the speeches that are already in use
      Out:
        List of indexes of selected speeches for the given session of the day
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
  Returns the list of 'events' (which is a struct like 'speech', but with 'begin' hour) of the speeches in the 
  list of speeches, given the begin_hour.
  
  Event struct = {begin: <event_begin_hour>, title: <event_name>, duration: <event_duration>}

  ##  In: 
        index: index to point to a certain speech in the list of speeches
        begin_hour: time that the current speech (Enum.at(speeches, index)) will begin
        speeches: List of speeches of a session of a track
      Out:
        List of events of a session of a track
  """
  def get_hours(index, begin_hour, speeches) do
    if (index < length(speeches)) do
      hour_list = String.split(begin_hour, ":")
      
      hour = String.to_integer(Enum.at(hour_list, 0))
      minutes = String.to_integer(Enum.at(hour_list, 1))
      
      speech = Enum.at(speeches, index)
      
      h = Enum.at(hour_and_minutes(speech, hour, minutes), 0)
      m = Enum.at(hour_and_minutes(speech, hour, minutes), 1)

      h = if (h < 10) do
            "0" <> to_string(h)
          else
            to_string(h)
          end

      m = if (m < 10) do
            "0" <> to_string(m)
          else
            to_string(m)
          end
      
      time = h <> ":" <> m
      
      event = %{begin: begin_hour, title: speech.title, duration: speech.duration}
      [event] ++ get_hours(index + 1, time, speeches)
    else
      []
    end
  end

  @doc """
  Return a track with its sessions and for each session its speeches containing 'begin', 'title' and 'duration'
  Track struct = {title: <track_name>, events: <events_list>, size: <events_length>}

  ##  In: 
        title: index to point to a certain speech in the list of speeches
        session_morning: time that the current speech (Enum.at(speeches, index)) will begin
        session_afternoon: List of speeches of a session of a track
      Out:
        Track with events set
  """
  def mount_track(title, session_morning, session_afternoon) do
    events = get_hours(0, "09:00", session_morning) 
    events = events ++ [%{begin: "12:00", title: "Almoço", duration: " "}]

    events = events ++ get_hours(0, "13:00", session_afternoon)
    events = events ++ [%{begin: "17:00", title: "Evento de Networking", duration: " "}]
    
    %{title: title, events: events, size: length(session_morning ++ session_afternoon) + 2}
  end

  @doc """
  Make the list of tracks for the given list speeches

  ##  In: 
        counter: index to point to a track_name for the track 
        speeches: List of speeches
        used_indexes: indexes of the speeches that are already in use
      Out:
        Tracks for the given list speeches
  """
  def make_tracks(counter, speeches, used_indexes) do
    if (length(used_indexes) < length(speeches)) do
      track_names = ["Track A", "Track B", "Track C", "Track D"]

      period_1 = 0
      period_2 = 1

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
      
      track = mount_track(Enum.at(track_names, counter), session_morning, session_afternoon)
      [track] ++ make_tracks(counter + 1, speeches, used_indexes)
    else
      []
    end
  end

  @doc """
  Return the list of tracks, using the list of speeches in a given file

  ##  In: 
        file_path: path to the file which contains the speeches
      Out:
        Tracks for the given file
  """
  def get_tracks(file_path) do
    file = File.read!(file_path)
    speeches = file_to_speeches(file)
    used_indexes = []
    make_tracks(0, speeches, used_indexes)
  end

end