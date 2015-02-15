require 'test_helper'

class FeAreasControllerTest < ActionController::TestCase
  def get_test_fe_area
    return {
      :fe_run_id => 1,
      :label => 'test_area',
      :category => 'test_category'
    }
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fe_areas)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fe_area" do
    assert_difference('FeArea.count') do
      post :create, :fe_area => get_test_fe_area
    end

    assert_redirected_to fe_area_path(assigns(:fe_area))
  end

  test "should show fe_area" do
    get :show, :id => fe_areas(:ally_area_one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fe_areas(:ally_area_one).to_param
    assert_response :success
  end

  test "should update fe_area" do
    put :update, :id => fe_areas(:ally_area_one).to_param, :fe_area => { }
    assert_redirected_to fe_area_path(assigns(:fe_area))
  end

  test "should destroy fe_area" do
    assert_difference('FeArea.count', -1) do
      delete :destroy, :id => fe_areas(:enemy_area_one).to_param
    end

    assert_redirected_to fe_areas_path
  end
end
