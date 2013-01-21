class Admin::UsersController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def admin
    @user = User.find(params[:id])
    @user.admin = !@user.admin
    @user.save

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end
end
