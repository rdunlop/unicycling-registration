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
  
  def club_admin
    @user = User.find(params[:id])

	respond_to do |format|
      if @user.update_attributes(params[:user])
        if @user.club_admin = false
          @user.club_admin = true
          @user.save
        end
        format.html { redirect_to admin_users_path, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        @user.club_admin = false
        @user.save
        format.html { redirect_to admin_users_path }
      end
    end
  end
end