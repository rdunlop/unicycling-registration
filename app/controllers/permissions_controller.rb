class PermissionsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource :user, :parent => false

  def index
    #authorize! :permissions, User
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
end
