class Admin::PermissionsController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource class: false

  def index
    @users = User.includes(:roles).all
  end

  def set_role
    @user = User.find(params[:user_id])
    role = params[:role_name]
    if User.roles.include?(role.to_sym)
      if @user.has_role? role
        @user.remove_role role
      else
        @user.add_role role
      end
      flash[:notice] = "Role updated"
    else
      flash[:alert] = "Role not found (#{role})"
    end

    redirect_to permissions_path
  end

  def set_password
    @user = User.find(params[:user_id])
    new_password = params[:password]

    @user.password = new_password
    @user.save!
    @user.confirm!

    redirect_to permissions_path
  end

  def create_race_official
    @competition = Competition.find(params[:competition_id])
    @user = User.find(params[:user_id])
    if @user.add_role(:race_official)
      redirect_to competition_judges_path(@competition), notice: 'Race Official successfully created.'
    else
      redirect_to competition_judges_path(@competiton), alert: 'Unable to add Race Official role to user.'
    end
  end

  def directors
    @events = Event.order(:name).all
  end
end
