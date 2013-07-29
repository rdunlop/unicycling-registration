class ApplicationController < ActionController::Base
  include ApplicationHelper
  include EventsHelper

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

  def render_common_pdf(view_name, orientation = "Portrait")
    render :pdf => view_name, 
      :print_media_type => true, 
      :margin => {:top => 2, :left => 2, :right => 2}, 
      :footer => default_footer, 
      :formats => [:html], 
      :orientation => orientation, 
      :layout => "pdf.html"
  end
end
