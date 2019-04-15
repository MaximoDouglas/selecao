defmodule Conference.ManagementTest do
  use Conference.DataCase
  alias Conference.Management
  
  @doc """
    author: MaximoDouglas
  """
  describe "management_module" do
    # File with numbers in its speeche names
    @mock_file_path "/home/douglas/dev/git/selecao/mock.proposals.txt"
    
    # File without numbers in its speeche names
    @file_path "/home/douglas/dev/git/selecao/proposals.txt"
    
    # Assert that the speeches returned by 'file_to_speeches/1' don't have numbers in its names
    test "file_to_speeches/1 return speeches of a given file" do
      speeches = Management.file_to_speeches(@file_path)
      assert Management.file_to_speeches(@mock_file_path) == speeches
    end

    # Begin time asserts
    test "get_tracks/1 return tracks" do
      tracks = Management.get_tracks(@file_path)

      for track <- tracks do
        event = Enum.at(track.events, 0)

        # Assert that the morning sessions of the tracks begins 09:00
        assert event.begin == "09:00"

        for i <- 0..(length(track.events) - 1) do
          if (Enum.at(track.events, i).title == "Almoço") do
            
            # Assert that the afternoon sessions of the tracks begins 13:00
            assert (Enum.at(track.events, i + 1)).begin == "13:00"
          end
        end
      end

      for track <- tracks do
        for i <- track.events do
          if (i.title == "Almoço") do
            # Assert that the 'Almoço' always begins at 12:00
            assert i.begin == "12:00"
          end

          if (i.title == "Evento de Networking") do
            # Assert that the 'Evento de Networking' always begins at 17:00
            assert i.begin == "17:00"
          end
        end
      end

    end
  end
end
