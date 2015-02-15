require 'test_helper'

class EmQueuesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:em_queues)
  end

  test "should show em_queue" do
    get :show, :id => :unengaged
    assert_response :success
  end
end
