class PermissionsController < ApplicationController
  before_filter :authenticate_user!, except: [:acl, :set_acl]
  authorize_resource class: false

  def acl
  end

  def set_acl
    if params[:access_key].to_i == modification_access_key
      set_reg_modifications_allowed(true)
      flash[:notice] = "Successfully Enabled Access"
    else
      set_reg_modifications_allowed(false)
      flash[:alert] = "Access Revoked"
    end
    redirect_to acl_permissions_path
  end

  def index
    @users = User.all
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

    respond_to do |format|
      format.html { redirect_to permissions_path }
    end
  end

  def create_race_official
    @competition = Competition.find(params[:competition_id])
    @user = User.find(params[:user_id])
    respond_to do |format|
      if @user.add_role(:race_official)
        format.html { redirect_to competition_judges_path(@competition), notice: 'Race Official successfully created.' }
      else
        format.html { redirect_to competition_judges_path(@competiton), alert: 'Unable to add Race Official role to user.' }
      end
    end
  end

  def directors
    @events = Event.order(:name).all
  end

end
