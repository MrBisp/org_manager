class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_organizations, only: %i[new create] #%i is a shortcut for an array of symbols.

  # GET /registrations/new - doesn't actually save it to the database.
  def new
    @user = User.new
  end

  def create
    begin
      # Extract user parameters separately from organization selection
      @user = User.new(
        email_address: params[:user][:email_address],
        password: params[:user][:password],
        password_confirmation: params[:user][:password_confirmation]
      )
      @user.role = :admin # Default role for new registrations
      
      # Check if creating a new organization
      if params[:user][:organization_id] == "new"
        # Create new organization
        @organization = Organization.new(name: params[:organization_name]) # We create a new organization with the name that the user entered.
        if @organization.save
          @user.organization = @organization # We assign the new organization to the user.
        else
          @organization.errors.each do |error|
            @user.errors.add(:base, "Organization #{error.attribute} #{error.message}") # We add the error to the user, which will be displayed in the form.
          end
          render :new, status: :unprocessable_entity and return
        end
      else
        # Use existing organization
        begin
          @user.organization_id = params[:user][:organization_id]
        rescue ActiveRecord::RecordNotFound 
          @user.errors.add(:organization_id, "not found")
          render :new, status: :unprocessable_entity and return # Rerenders the form with the error message.
        end
      end
      
      # Try to save the user
      if @user.save
        start_new_session_for(@user)
        redirect_to root_path, notice: "Welcome! You have successfully signed up."
      else
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::InvalidForeignKey
      @user.errors.add(:organization_id, "is invalid. Please select a valid organization")
      render :new, status: :unprocessable_entity
    rescue ActiveRecord::RecordNotUnique
      @user.errors.add(:email_address, "has already been taken")
      render :new, status: :unprocessable_entity
    end
  end

  private
    def set_organizations
      @organizations = Organization.all
    end
end 