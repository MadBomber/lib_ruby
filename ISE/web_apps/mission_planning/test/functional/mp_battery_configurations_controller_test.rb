require 'test_helper'

class MpBatteryConfigurationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_battery_configurations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_battery_configuration" do
    assert_difference('MpBatteryConfiguration.count') do
      post :create, :mp_battery_configuration => { }
    end

    assert_redirected_to mp_battery_configuration_path(assigns(:mp_battery_configuration))
  end

  test "should show mp_battery_configuration" do
    get :show, :id => mp_battery_configurations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_battery_configurations(:one).to_param
    assert_response :success
  end

  test "should update mp_battery_configuration" do
    put :update, :id => mp_battery_configurations(:one).to_param, :mp_battery_configuration => { }
    assert_redirected_to mp_battery_configuration_path(assigns(:mp_battery_configuration))
  end

  test "should destroy mp_battery_configuration" do
    assert_difference('MpBatteryConfiguration.count', -1) do
      delete :destroy, :id => mp_battery_configurations(:one).to_param
    end

    assert_redirected_to mp_battery_configurations_path
  end
end
