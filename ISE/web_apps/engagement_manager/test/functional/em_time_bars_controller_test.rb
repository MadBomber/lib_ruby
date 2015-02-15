require 'test_helper'

class EmTimeBarsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:em_time_bars)
  end

  test "should show em_time_bar" do
    get :show, :id => em_time_bars(:one).to_param
    assert_response :success
  end
end
