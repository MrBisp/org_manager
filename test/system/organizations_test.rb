require "application_system_test_case"

class OrganizationsTest < ApplicationSystemTestCase
  # Direct login helper method
  def login_as(user, password = "password")
    visit new_session_url
    assert_text "Sign in"
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button "Sign in"
    sleep 1
  end

  setup do
    @organization = organizations(:one)
    @user = users(:one)
    login_as(@user)
  end

  test "visiting the index" do
    assert_selector "nav", text: @user.email_address
    visit organizations_url
    assert_selector "h1", text: "Organizations"
  end

  test "should create organization" do
    visit new_organization_url
    fill_in "organization_name", with: "Test New Organization"
    click_on "Create Organization"
    
    # Assert we're on the show page by checking for the organization name
    assert_text "Test New Organization" 
    click_on "Back to organizations"
  end

  test "should update Organization" do
    visit organization_url(@organization)
    click_on "Edit this organization"
    fill_in "organization_name", with: "Updated Organization Name"
    click_on "Update Organization"
    assert_text "Updated Organization Name"
    click_on "Back to organizations"
  end

  test "should destroy Organization" do
    visit new_organization_url
    fill_in "organization_name", with: "Organization to Delete"
    click_on "Create Organization"
    assert_text "Organization to Delete"
    
    click_button "Destroy this organization"
    page.driver.browser.switch_to.alert.accept rescue nil
    
    assert_selector "h1", text: "Organizations"
  end
end
