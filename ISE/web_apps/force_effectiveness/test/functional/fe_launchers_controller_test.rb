require 'test_helper'

class FeLaunchersControllerTest < ActionController::TestCase
  def get_test_fe_launcher
    return {
      :fe_run_id => 1,
      :label => 'test_launcher',
      :category => 'test_category'
    }
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fe_launchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fe_launcher" do
    assert_difference('FeLauncher.count') do
      post :create, :fe_launcher => get_test_fe_launcher
    end

    assert_redirected_to fe_launcher_path(assigns(:fe_launcher))
  end

  test "should show fe_launcher" do
    get :show, :id => fe_launchers(:test_gemt_launcher).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fe_launchers(:test_gemt_launcher).to_param
    assert_response :success
  end

  test "should update fe_launcher" do
    put :update, :id => fe_launchers(:test_gemt_launcher).to_param, :fe_launcher => { }
    assert_redirected_to fe_launcher_path(assigns(:fe_launcher))
  end

  test "should destroy fe_launcher" do
    assert_difference('FeLauncher.count', -1) do
      delete :destroy, :id => fe_launchers(:test_pac3_launcher).to_param
    end

    assert_redirected_to fe_launchers_path
  end
end
