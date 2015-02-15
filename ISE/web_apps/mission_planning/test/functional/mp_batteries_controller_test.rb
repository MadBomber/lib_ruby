require 'test_helper'

class MpBatteriesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_batteries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_battery" do
    assert_difference('MpBattery.count') do
      post :create, :mp_battery => { }
    end

    assert_redirected_to mp_battery_path(assigns(:mp_battery))
  end

  test "should show mp_battery" do
    get :show, :id => mp_batteries(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_batteries(:one).to_param
    assert_response :success
  end

  test "should update mp_battery" do
    put :update, :id => mp_batteries(:one).to_param, :mp_battery => { }
    assert_redirected_to mp_battery_path(assigns(:mp_battery))
  end

  test "should destroy mp_battery" do
    assert_difference('MpBattery.count', -1) do
      delete :destroy, :id => mp_batteries(:one).to_param
    end

    assert_redirected_to mp_batteries_path
  end
end
