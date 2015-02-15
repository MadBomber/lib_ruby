require 'test_helper'

class FeRunsControllerTest < ActionController::TestCase
  def get_test_fe_run
    return {
      :guid => 'test_guid',
      :mp_scenario_id => 1,
      :mp_tewa_configuration_id => 2,
      :time => '2010-01-01 00:00:00',
    }
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fe_runs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fe_run" do
    assert_difference('FeRun.count') do
      post :create, :fe_run => get_test_fe_run
    end

    assert_redirected_to fe_run_path(assigns(:fe_run))
  end

  test "should show fe_run" do
    get :show, :id => fe_runs(:test_run).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fe_runs(:test_run).to_param
    assert_response :success
  end

  test "should update fe_run" do
    put :update, :id => fe_runs(:test_run).to_param, :fe_run => { }
    assert_redirected_to fe_run_path(assigns(:fe_run))
  end

  test "should destroy fe_run" do
    assert_difference('FeRun.count', -1) do
      delete :destroy, :id => fe_runs(:other_test_run).to_param
    end

    assert_redirected_to fe_runs_path
  end
end
