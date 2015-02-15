require 'test_helper'

class EmMessagesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:em_messages)
  end
end
