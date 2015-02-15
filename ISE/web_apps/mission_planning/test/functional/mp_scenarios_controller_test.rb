require 'test_helper'

class MpScenariosControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:mp_scenarios)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create mp_scenario" do
    assert_difference('MpScenario.count') do
      post :create, :mp_scenario => { }
    end

    assert_redirected_to mp_scenario_path(assigns(:mp_scenario))
  end

  test "should show mp_scenario" do
    get :show, :id => mp_scenarios(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => mp_scenarios(:one).to_param
    assert_response :success
  end

  test "should update mp_scenario" do
    put :update, :id => mp_scenarios(:one).to_param, :mp_scenario => { }
    assert_redirected_to mp_scenario_path(assigns(:mp_scenario))
  end

  test "should destroy mp_scenario" do
    assert_difference('MpScenario.count', -1) do
      delete :destroy, :id => mp_scenarios(:one).to_param
    end

    assert_redirected_to mp_scenarios_path
  end
end
