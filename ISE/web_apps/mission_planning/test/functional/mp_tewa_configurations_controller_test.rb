require 'test_helper'

class MpTewaConfigurationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_tewa_configurations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_tewa_configuration" do
    assert_difference('MpTewaConfiguration.count') do
      post :create, :mp_tewa_configuration => { }
    end

    assert_redirected_to mp_tewa_configuration_path(assigns(:mp_tewa_configuration))
  end

  test "should show mp_tewa_configuration" do
    get :show, :id => mp_tewa_configurations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_tewa_configurations(:one).to_param
    assert_response :success
  end

  test "should update mp_tewa_configuration" do
    put :update, :id => mp_tewa_configurations(:one).to_param, :mp_tewa_configuration => { }
    assert_redirected_to mp_tewa_configuration_path(assigns(:mp_tewa_configuration))
  end

  test "should destroy mp_tewa_configuration" do
    assert_difference('MpTewaConfiguration.count', -1) do
      delete :destroy, :id => mp_tewa_configurations(:one).to_param
    end

    assert_redirected_to mp_tewa_configurations_path
  end
end
