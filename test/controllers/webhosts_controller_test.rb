require 'test_helper'

class WebhostsControllerTest < ActionController::TestCase
  setup do
    @webhost = webhosts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:webhosts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create webhost" do
    assert_difference('Webhost.count') do
      post :create, webhost: { attackID: @webhost.attackID, name: @webhost.name }
    end

    assert_redirected_to webhost_path(assigns(:webhost))
  end

  test "should show webhost" do
    get :show, id: @webhost
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @webhost
    assert_response :success
  end

  test "should update webhost" do
    patch :update, id: @webhost, webhost: { attackID: @webhost.attackID, name: @webhost.name }
    assert_redirected_to webhost_path(assigns(:webhost))
  end

  test "should destroy webhost" do
    assert_difference('Webhost.count', -1) do
      delete :destroy, id: @webhost
    end

    assert_redirected_to webhosts_path
  end
end
