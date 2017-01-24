require 'test_helper'

class AttacksControllerTest < ActionController::TestCase
  setup do
    @attack = attacks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:attacks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create attack" do
    assert_difference('Attack.count') do
      post :create, attack: { attack_type: @attack.attack_type, case_id: @attack.case_id, client: @attack.client, detection_method: @attack.detection_method, detection_time: @attack.detection_time, notes: @attack.notes, url: @attack.url }
    end

    assert_redirected_to attack_path(assigns(:attack))
  end

  test "should show attack" do
    get :show, id: @attack
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @attack
    assert_response :success
  end

  test "should update attack" do
    patch :update, id: @attack, attack: { attack_type: @attack.attack_type, case_id: @attack.case_id, client: @attack.client, detection_method: @attack.detection_method, detection_time: @attack.detection_time, notes: @attack.notes, url: @attack.url }
    assert_redirected_to attack_path(assigns(:attack))
  end

  test "should destroy attack" do
    assert_difference('Attack.count', -1) do
      delete :destroy, id: @attack
    end

    assert_redirected_to attacks_path
  end
end
