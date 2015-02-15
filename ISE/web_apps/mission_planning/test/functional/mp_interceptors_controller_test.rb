require 'test_helper'

class MpInterceptorsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_interceptors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_interceptor" do
    assert_difference('MpInterceptor.count') do
      post :create, :mp_interceptor => { }
    end

    assert_redirected_to mp_interceptor_path(assigns(:mp_interceptor))
  end

  test "should show mp_interceptor" do
    get :show, :id => mp_interceptors(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_interceptors(:one).to_param
    assert_response :success
  end

  test "should update mp_interceptor" do
    put :update, :id => mp_interceptors(:one).to_param, :mp_interceptor => { }
    assert_redirected_to mp_interceptor_path(assigns(:mp_interceptor))
  end

  test "should destroy mp_interceptor" do
    assert_difference('MpInterceptor.count', -1) do
      delete :destroy, :id => mp_interceptors(:one).to_param
    end

    assert_redirected_to mp_interceptors_path
  end
end
