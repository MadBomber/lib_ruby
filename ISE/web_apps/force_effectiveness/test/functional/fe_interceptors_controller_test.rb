require 'test_helper'

class FeInterceptorsControllerTest < ActionController::TestCase
  def get_test_fe_interceptor
    return {
      :fe_run_id => 1,
      :label => 'test_interceptor',
      :category => 'test_category',
      :fe_engagement_id => 2,
      :status => 'test_status',
    }
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fe_interceptors)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fe_interceptor" do
    assert_difference('FeInterceptor.count') do
      post :create, :fe_interceptor => get_test_fe_interceptor
    end

    assert_redirected_to fe_interceptor_path(assigns(:fe_interceptor))
  end

  test "should show fe_interceptor" do
    get :show, :id => fe_interceptors(:unlaunched_test_interceptor).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fe_interceptors(:unlaunched_test_interceptor).to_param
    assert_response :success
  end

  test "should update fe_interceptor" do
    put :update, :id => fe_interceptors(:unlaunched_test_interceptor).to_param, :fe_interceptor => { }
    assert_redirected_to fe_interceptor_path(assigns(:fe_interceptor))
  end

  test "should destroy fe_interceptor" do
    assert_difference('FeInterceptor.count', -1) do
      delete :destroy, :id => fe_interceptors(:flying_test_interceptor).to_param
    end

    assert_redirected_to fe_interceptors_path
  end
end
