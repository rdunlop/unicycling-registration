class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  check_authorization :unless => :devise_controller?
  skip_authorization_check :if => :rails_admin_controller?

  def rails_admin_controller?
    false
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  before_filter :load_config_object

  def load_config_object
    if EventConfiguration.count == 0
      @config = EventConfiguration.new
    else
      @config = EventConfiguration.first
    end
  end

  def default_footer
    {:left => '[date] [time]', :center => @config.short_name, :right => '[page] of [topage]'}
  end
end
