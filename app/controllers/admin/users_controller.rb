class Admin::UsersController < Admin::BaseController
  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @users = User.all
  end

  def admin
    @user = User.find(params[:id])
    if @user.has_role? :admin
      @user.remove_role :admin
    else
      @user.add_role :admin
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path }
    end
  end

  def club_admin
    @user = User.find(params[:id])
    @user.club = params[:user][:club]
    @user.save
    if @user.has_role? :club_admin
      @user.remove_role :club_admin
    else
      @user.add_role :club_admin
    end

    respond_to do |format|
      format.html { redirect_to admin_users_path, notice: 'User was successfully updated.' }
    end
  end
end
