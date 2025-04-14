require "application_system_test_case"
require "securerandom"

class OrganizationsTest < ApplicationSystemTestCase
  # Direct login helper method - wait for navbar proof of login
  def login_as(user, password = "password")
    visit new_session_url
    assert_text "Sign in"
    fill_in "email_address", with: user.email_address
    fill_in "password", with: password
    click_button "Sign in"

    # Add debugging right after the click
    sleep 0.5 # Small pause for potential redirect/render
    puts "[Debug Login] Current URL after Sign In click: #{page.current_url}"
    puts "[Debug Login] Page title: #{page.title}"
    puts "[Debug Login] Page HTML snippet: #{page.html.slice(0, 500)}"

    # Wait for navigation/login to complete by asserting the navbar content
    assert_selector "nav", text: user.email_address, wait: 10 # Increased wait time for this specific assertion

    # Sanity check: Ensure we are also on the expected page (index)
    assert_selector "h1", text: "Organizations"
  end

  setup do
    @organization = organizations(:one)
    @user = users(:one)
    # login_as(@user) # Removed from setup
  end

  test "visiting the index" do
    login_as(@user) # Login at the start of the test
    # We should already be on the index page after login
    assert_selector "h1", text: "Organizations"
    assert_selector "nav", text: @user.email_address
  end

  test "should create organization" do
    login_as(@user) # Login at the start of the test
    visit new_organization_url
    assert_selector "h1", text: "New organization"

    # Use a unique name to avoid validation conflicts
    unique_name = "Test New Org #{SecureRandom.hex(4)}"
    fill_in "Name", with: unique_name

    # Submit form
    click_on "Create Organization"

    # Verify we landed on the SHOW page by checking for unique elements
    assert_text unique_name
    assert_selector ".actions-bar" # Element unique to show page
    assert page.has_link?("Back to organizations") # Check link exists

    # Now click back
    click_on "Back to organizations"

    # Verify we are back on the index page
    assert_selector "h1", text: "Organizations"
  end

  # Split into separate tests for clarity
  test "should show organization and edit link" do
    login_as(@user) # Login at the start of the test
    visit organization_url(@organization)

    # Verify we're on the show page by checking for the name and actions
    assert_text @organization.name
    assert_selector ".actions-bar"
    assert page.has_link?("Edit this organization")
  end

  test "should edit organization" do
    login_as(@user) # Login at the start of the test
    visit edit_organization_url(@organization)

    # Verify we're on the edit page
    assert_selector "h1", text: "Editing organization"

    # Use a unique name to avoid validation conflicts
    updated_unique_name = "Updated Org #{SecureRandom.hex(4)}"
    fill_in "Name", with: updated_unique_name

    # Submit the form
    click_on "Update Organization"

    # Verify we landed back on the SHOW page with the updated name
    assert_text updated_unique_name
    assert_selector ".actions-bar" # Unique element on show page
    assert page.has_link?("Back to organizations") # Check link exists

    # Go back to index
    click_on "Back to organizations"
    assert_selector "h1", text: "Organizations"
  end

  test "should destroy Organization" do
    login_as(@user) # Login at the start of the test

    # Use a unique name to avoid validation conflicts during creation
    org_to_delete_name = "Org to Delete #{SecureRandom.hex(4)}"

    # Create organization specifically for deletion in this test
    visit new_organization_url
    assert_selector "h1", text: "New organization"

    fill_in "Name", with: org_to_delete_name
    click_on "Create Organization"

    # --- Debugging ---
    # puts "[Debug Destroy] HTML after create attempt:"
    # puts page.html
    # --- End Debugging ---

    # Verify we landed on the show page for the org to be deleted
    # First, wait for an element unique to the show page
    assert_selector ".actions-bar"
    # Now assert the text is present
    assert_text org_to_delete_name
    # Check for the button again
    assert page.has_button?("Destroy this organization") # More specific check

    # Click destroy and accept confirmation
    click_button "Destroy this organization"
    page.driver.browser.switch_to.alert.accept rescue nil

    # Verify we're back on the index page (implicitly waits)
    assert_selector "h1", text: "Organizations"
    # Also verify the deleted org name is gone
    assert_no_text org_to_delete_name
  end
end
