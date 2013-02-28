class Admin::BaseController < ApplicationController

  # may want to change this to https://github.com/ryanb/cancan/wiki/Admin-Namespace
  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end
end
