require 'test_helper'

class MpLaunchersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_launchers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_launcher" do
    assert_difference('MpLauncher.count') do
      post :create, :mp_launcher => { }
    end

    assert_redirected_to mp_launcher_path(assigns(:mp_launcher))
  end

  test "should show mp_launcher" do
    get :show, :id => mp_launchers(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_launchers(:one).to_param
    assert_response :success
  end

  test "should update mp_launcher" do
    put :update, :id => mp_launchers(:one).to_param, :mp_launcher => { }
    assert_redirected_to mp_launcher_path(assigns(:mp_launcher))
  end

  test "should destroy mp_launcher" do
    assert_difference('MpLauncher.count', -1) do
      delete :destroy, :id => mp_launchers(:one).to_param
    end

    assert_redirected_to mp_launchers_path
  end
end
