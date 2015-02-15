require 'test_helper'

class MpTewaFactorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_tewa_factors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_tewa_factor" do
    assert_difference('MpTewaFactor.count') do
      post :create, :mp_tewa_factor => { }
    end

    assert_redirected_to mp_tewa_factor_path(assigns(:mp_tewa_factor))
  end

  test "should show mp_tewa_factor" do
    get :show, :id => mp_tewa_factors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_tewa_factors(:one).to_param
    assert_response :success
  end

  test "should update mp_tewa_factor" do
    put :update, :id => mp_tewa_factors(:one).to_param, :mp_tewa_factor => { }
    assert_redirected_to mp_tewa_factor_path(assigns(:mp_tewa_factor))
  end

  test "should destroy mp_tewa_factor" do
    assert_difference('MpTewaFactor.count', -1) do
      delete :destroy, :id => mp_tewa_factors(:one).to_param
    end

    assert_redirected_to mp_tewa_factors_path
  end
end
