require 'test_helper'

class EmThreatsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:em_threats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create em_threat" do
    assert_difference('EmThreat.count') do
      post :create, :em_threat => { }
    end

    assert_redirected_to em_threat_path(assigns(:em_threat))
  end

  test "should show em_threat" do
    get :show, :id => em_threats(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => em_threats(:one).to_param
    assert_response :success
  end

  test "should update em_threat" do
    put :update, :id => em_threats(:one).to_param, :em_threat => { }
    assert_redirected_to em_threat_path(assigns(:em_threat))
  end

  test "should destroy em_threat" do
    assert_difference('EmThreat.count', -1) do
      delete :destroy, :id => em_threats(:one).to_param
    end

    assert_redirected_to em_threats_path
  end
end
