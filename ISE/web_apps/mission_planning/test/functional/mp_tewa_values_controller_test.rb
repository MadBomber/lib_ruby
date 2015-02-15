require 'test_helper'

class MpTewaValuesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_tewa_values)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_tewa_value" do
    assert_difference('MpTewaValue.count') do
      post :create, :mp_tewa_value => { }
    end

    assert_redirected_to mp_tewa_value_path(assigns(:mp_tewa_value))
  end

  test "should show mp_tewa_value" do
    get :show, :id => mp_tewa_values(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_tewa_values(:one).to_param
    assert_response :success
  end

  test "should update mp_tewa_value" do
    put :update, :id => mp_tewa_values(:one).to_param, :mp_tewa_value => { }
    assert_redirected_to mp_tewa_value_path(assigns(:mp_tewa_value))
  end

  test "should destroy mp_tewa_value" do
    assert_difference('MpTewaValue.count', -1) do
      delete :destroy, :id => mp_tewa_values(:one).to_param
    end

    assert_redirected_to mp_tewa_values_path
  end
end
