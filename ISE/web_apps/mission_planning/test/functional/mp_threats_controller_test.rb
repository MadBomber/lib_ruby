require 'test_helper'

class MpThreatsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_threats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_threat" do
    assert_difference('MpThreat.count') do
      post :create, :mp_threat => { }
    end

    assert_redirected_to mp_threat_path(assigns(:mp_threat))
  end

  test "should show mp_threat" do
    get :show, :id => mp_threats(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_threats(:one).to_param
    assert_response :success
  end

  test "should update mp_threat" do
    put :update, :id => mp_threats(:one).to_param, :mp_threat => { }
    assert_redirected_to mp_threat_path(assigns(:mp_threat))
  end

  test "should destroy mp_threat" do
    assert_difference('MpThreat.count', -1) do
      delete :destroy, :id => mp_threats(:one).to_param
    end

    assert_redirected_to mp_threats_path
  end
end
