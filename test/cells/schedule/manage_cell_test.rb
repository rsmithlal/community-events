require 'test_helper'

class Schedule::ManageCellTest < Cell::TestCase
  test "display" do
    invoke :display
    assert_select "p"
  end
  

end