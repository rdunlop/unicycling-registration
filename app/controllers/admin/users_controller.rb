class Admin::UsersController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def role
    @user = User.find(params[:id])
    role = params[:role_name]
    if User.roles.include?(role.to_sym)
      if @user.has_role? role
        @user.remove_role role
      else
        @user.add_role role
      end
    else
      flash[:alert] = "Role not found (#{role})"
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end
end
