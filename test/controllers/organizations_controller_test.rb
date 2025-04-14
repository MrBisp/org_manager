require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @user = users(:one) # Admin user from fixture
    
    # Sign in as admin
    post session_url, params: { email_address: @user.email_address, password: "password" }
  end

  test "should get index" do
    get organizations_url
    assert_response :success
  end

  test "should get new" do
    get new_organization_url
    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      post organizations_url, params: { organization: { name: "New Organization" } }
    end

    assert_redirected_to organization_url(Organization.last)
  end

  test "should show organization" do
    get organization_url(@organization)
    assert_response :success
  end

  test "should get edit" do
    get edit_organization_url(@organization)
    assert_response :success
  end

  test "should update organization" do
    patch organization_url(@organization), params: { organization: { name: "Updated Name" } }
    assert_redirected_to organization_url(@organization)
  end

  test "should destroy organization" do
    # We can't delete the organization the user belongs to, so create a new one
    new_org = Organization.create!(name: "To Be Deleted")
    
    assert_difference("Organization.count", -1) do
      delete organization_url(new_org)
    end

    assert_redirected_to organizations_url
  end
end
