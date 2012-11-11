class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization :unless => :devise_controller?

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
end
