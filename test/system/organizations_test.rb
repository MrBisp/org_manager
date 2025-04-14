require "application_system_test_case"

class OrganizationsTest < ApplicationSystemTestCase
  # Direct login helper method
  def login_as(user, password = "password")
    # Ensure we're on the login page
    visit new_session_url
    assert_text "Sign in"
    
    # Fill in credentials
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    
    # Submit the form
    click_button "Sign in"
    
    # Wait for redirect to complete
    sleep 1
  end

  setup do
    @organization = organizations(:one)
    @user = users(:one)
    
    # Login with user from fixtures
    login_as(@user)
  end

  test "visiting the index" do
    # First make sure we're logged in by checking for the nav bar
    assert_selector "nav", text: @user.email_address
    
    # Now visit the organizations index
    visit organizations_url
    
    # Wait for the page to load
    sleep 1
    
    # Verify that we're on the organizations page
    assert_selector "h1", text: "Organizations"
  end

  test "should create organization" do
    visit organizations_url
    
    # Debug - print if the button exists
    if page.has_link?("New organization")
      puts "Found New organization link"
    else
      puts "New organization link not found"
      puts page.body
    end
    
    click_on "New organization"

    fill_in "organization[name]", with: "Test New Organization"
    click_on "Create Organization"

    assert_text "Organization was successfully created"
    click_on "Back"
  end

  test "should update Organization" do
    visit organization_url(@organization)
    
    # Debug - print if the button exists
    if page.has_link?("Edit this organization")
      puts "Found Edit this organization link"
    else
      puts "Edit this organization link not found"
      puts page.body
    end
    
    click_on "Edit this organization", match: :first

    fill_in "organization[name]", with: "Updated Organization Name"
    click_on "Update Organization"

    assert_text "Organization was successfully updated"
    click_on "Back"
  end

  test "should destroy Organization" do
    # Create a new organization that we can safely delete
    visit new_organization_url
    
    fill_in "organization[name]", with: "Organization to Delete"
    click_on "Create Organization"
    
    # Now visit the organization page and delete it
    # Debug - the destroy action is a button_to, not a link
    if page.has_button?("Destroy this organization")
      puts "Found Destroy this organization button"
    else
      puts "Destroy this organization button not found"
      puts page.body
    end
    
    # Click the button which will trigger a confirmation dialog
    click_button "Destroy this organization"
    
    # Accept the confirmation dialog
    page.driver.browser.switch_to.alert.accept rescue nil

    assert_text "Organization was successfully destroyed"
  end
end
