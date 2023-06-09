class AdminUpgradesController < ApplicationController
  before_action :authenticate_user!
  before_action :skip_authorization

  def new; end

  def create
    new_role = nil
    if params[:access_code] == Rails.configuration.super_admin_upgrade_code
      new_role = :super_admin
    elsif params[:access_code] == @tenant.admin_upgrade_code
      new_role = :convention_admin
    else
      raise Pundit::NotAuthorizedError.new("Incorrect Access code")
    end

    current_user.add_role new_role
    flash[:notice] = "Successfully upgraded to #{new_role}"
    redirect_to root_path
  end
end
