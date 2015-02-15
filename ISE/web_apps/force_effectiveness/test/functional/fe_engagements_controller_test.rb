require 'test_helper'

class FeEngagementsControllerTest < ActionController::TestCase
  def get_test_fe_engagement
    return {
      :fe_run_id => 1,
      :fe_launcher_id => '2',
      :fe_threat_id => '3',
      :status => 'test_status'
    }
  end
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fe_engagements)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fe_engagement" do
    assert_difference('FeEngagement.count') do
      post :create, :fe_engagement => get_test_fe_engagement
    end

    assert_redirected_to fe_engagement_path(assigns(:fe_engagement))
  end

  test "should show fe_engagement" do
    get :show, :id => fe_engagements(:test_engagement_one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => fe_engagements(:test_engagement_one).to_param
    assert_response :success
  end

  test "should update fe_engagement" do
    put :update, :id => fe_engagements(:test_engagement_one).to_param, :fe_engagement => { }
    assert_redirected_to fe_engagement_path(assigns(:fe_engagement))
  end

  test "should destroy fe_engagement" do
    assert_difference('FeEngagement.count', -1) do
      delete :destroy, :id => fe_engagements(:test_engagement_two).to_param
    end

    assert_redirected_to fe_engagements_path
  end
end
