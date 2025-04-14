class UsersController < ApplicationController
  before_action :set_organization
  before_action :set_user, only: %i[ show edit update destroy ]
  before_action :require_admin, except: %i[ index show ]

  def index
    @users = @organization.users
  end

  def show
  end

  def new
    @user = @organization.users.build
  end

  def edit
  end

  def create
    @user = @organization.users.build(user_params)

    if @user.save
      redirect_to organization_users_path(@organization), notice: "User was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      redirect_to organization_users_path(@organization), notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to organization_users_path(@organization), notice: "User was successfully removed."
  end

  def assign
    # Get all users not in this organization
    @available_users = User.where.not(organization_id: @organization.id)
  end

  def update_assignment
    @user = User.find(params[:user_id])
    
    if @user.update(organization: @organization)
      redirect_to organization_users_path(@organization), notice: "User was successfully assigned to organization."
    else
      redirect_to assign_organization_users_path(@organization), alert: "Failed to assign user to organization."
    end
  end

  private
    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    def set_user
      @user = @organization.users.find(params[:id])
    end

    def require_admin
      unless Current.user&.admin?
        redirect_to organization_users_path(@organization), alert: "You must be an admin to perform this action."
      end
    end

    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
    end
end