class ApplicationController < ActionController::Base
  include ApplicationHelper
  include EventsHelper

  before_filter :set_locale

  protect_from_forgery
  check_authorization :unless => :devise_controller?
  skip_authorization_check :if => :rails_admin_controller?

  def rails_admin_controller?
    false
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { locale: I18n.locale }
  end

  def set_locale
    if params[:locale].blank?
      I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
    elsif I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    end
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
    {:left => '[date] [time]', :center => @config.short_name, :right => 'Page [page] of [topage]'}
  end

  def render_common_pdf(view_name, orientation = "Portrait", attachment = false)
    if attachment
      disposition = "attachment"
    else
      disposition = "inline"
    end

    render :pdf => view_name,
      :print_media_type => true,
      :margin => {:top => 2, :left => 2, :right => 2},
      :footer => default_footer,
      :formats => [:html],
      :orientation => orientation,
      :disposition => disposition,
      :layout => "pdf.html"
  end
end
