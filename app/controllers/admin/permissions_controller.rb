class Admin::PermissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_permission

  def index
    @available_roles = current_user.roles_accessible
  end

  def set_role
    @user = User.this_tenant.find(params[:user_id])
    role = params[:role_name]
    if check_role_access(role)
      if @user.has_role? role
        @user.remove_role role
      else
        @user.add_role role
      end
      flash[:notice] = I18n.t("admin.permissions.role_updated")
    end

    redirect_to permissions_path
  end

  def add_role
    params[:users_id].each do |user_id|
      @user = User.this_tenant.find(user_id)
      params[:roles_names].each do |role|
        next unless check_role_access(role)

        if @user.has_role? role
          flash[:alert] = I18n.t("admin.permissions.user_already_has_role", user: @user, role: role.to_s.humanize)
        else
          @user.add_role role
          flash[:notice] = I18n.t("admin.permissions.role_updated")
        end
      end
    end

    redirect_to permissions_path
  end

  def remove_roles
    @user = User.this_tenant.find(params[:user_id])
    params[:roles].each do |role|
      if check_role_access(role)
        @user.remove_role role
      end
      flash[:notice] = I18n.t("admin.permissions.role_updated")
    end

    redirect_to permissions_path
  end

  def set_password
    @user = User.this_tenant.find(params[:user_id])
    new_password = params[:password]

    @user.password = new_password

    if @user.save
      @user.confirm
      flash[:notice] = "Updated Password for #{@user}"
    else
      flash[:alert] = "Invalid Password"
    end
    redirect_to permissions_path
  end

  private

  def authorize_permission
    authorize :admin_permission
  end

  def check_role_access(role)
    unless current_user.roles_accessible.include?(role.to_sym)
      flash[:alert] = I18n.t("admin.permissions.role_not_found", role: role)
      return false
    end

    true
  end
end
