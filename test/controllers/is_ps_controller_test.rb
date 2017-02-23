require 'test_helper'

class IsPsControllerTest < ActionController::TestCase
  setup do
    @isp = isps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:isps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create isp" do
    assert_difference('Isp.count') do
      post :create, isp: { attackID: @isp.attackID, name: @isp.name }
    end

    assert_redirected_to isp_path(assigns(:isp))
  end

  test "should show isp" do
    get :show, id: @isp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @isp
    assert_response :success
  end

  test "should update isp" do
    patch :update, id: @isp, isp: { attackID: @isp.attackID, name: @isp.name }
    assert_redirected_to isp_path(assigns(:isp))
  end

  test "should destroy isp" do
    assert_difference('Isp.count', -1) do
      delete :destroy, id: @isp
    end

    assert_redirected_to isps_path
  end
end
