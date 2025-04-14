require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one)
    # Log in as admin user
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get organization_users_url(@organization)
    assert_response :success
  end

  test "should get show" do
    get organization_user_url(@organization, @user)
    assert_response :success
  end

  test "should get new" do
    get new_organization_user_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_user_url(@organization, @user)
    assert_response :success
  end
end
