require 'test_helper'

class FeThreatsControllerTest < ActionController::TestCase
  def get_test_fe_threat
    return {
      :fe_run_id => 1,
      :label => 'test_threat',
      :category => 'test_category',
      :target_area_id => 2,
      :source_area_id => 3,
      :status => 'test_status'
    }
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fe_threats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fe_threat" do
    assert_difference('FeThreat.count') do
      post :create, :fe_threat => get_test_fe_threat
    end

    assert_redirected_to fe_threat_path(assigns(:fe_threat))
  end

  test "should show fe_threat" do
    get :show, :id => fe_threats(:flying_test_threat).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fe_threats(:flying_test_threat).to_param
    assert_response :success
  end

  test "should update fe_threat" do
    put :update, :id => fe_threats(:flying_test_threat).to_param, :fe_threat => { }
    assert_redirected_to fe_threat_path(assigns(:fe_threat))
  end

  test "should destroy fe_threat" do
    assert_difference('FeThreat.count', -1) do
      delete :destroy, :id => fe_threats(:impacted_test_threat).to_param
    end

    assert_redirected_to fe_threats_path
  end
end
