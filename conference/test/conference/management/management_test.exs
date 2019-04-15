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

    test "file_to_speeches/1 return speeches withou numbers in its names" do
      speeches = Management.file_to_speeches(@file_path)
      assert Management.file_to_speeches(@mock_file_path) == speeches
    end
  end
end
