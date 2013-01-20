class Admin::BaseController < ApplicationController
  before_filter :verify_admin

  # may want to change this to https://github.com/ryanb/cancan/wiki/Admin-Namespace
  #
  # NOTE: http://www.rubyfleebie.com/restful-admin-controllers-and-views-with-rails/

  def verify_admin
    redirect_to root_url unless (current_user.admin? or current_user.super_admin?)
  end
end
