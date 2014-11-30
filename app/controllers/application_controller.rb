class ApplicationController < ActionController::Base
  include ApplicationHelper
  include EventsHelper

  before_filter :set_locale
  before_filter :set_home_breadcrumb, unless: :rails_admin_controller?

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
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_path, :alert => exception.message
  end
  before_filter :load_config_object

  def load_config_object
    @config = EventConfiguration.singleton
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
      :page_size => "Letter",
      :print_media_type => true,
      :margin => {:top => 2, :left => 2, :right => 2},
      :footer => default_footer,
      :formats => [:html],
      :orientation => orientation,
      :disposition => disposition,
      :layout => "pdf.html"
  end

  # a prototype, not working (currently cutting off lines)
  def render_pdf_with_header(view_name, template, locals)

    render :pdf => view_name,
      :page_size => "Letter",
      :print_media_type => true,
      :margin => {:top => 60, :left => 2, :right => 2},
      :footer => default_footer,
      :formats => [:html],
      :header =>{ :html => {template: template, locals: locals}},
      :orientation => "Portrait",
      :disposition => "inline",
      :layout => "pdf.html"
  end

  private

  def set_home_breadcrumb
    add_breadcrumb "Home", root_path
  end

  def add_registrant_breadcrumb(registrant)
    add_breadcrumb "##{registrant.bib_number} - #{registrant}", registrant_path(registrant)
  end

  def add_payment_summary_breadcrumb
    add_breadcrumb "Payments Summary", summary_payments_path
  end

  def add_category_breadcrumb(category)
    add_breadcrumb "#{category}"
  end

  def add_event_breadcrumb(event)
    add_breadcrumb "#{event}", event_path(event)
  end

  def add_competition_breadcrumb(competition)
    add_breadcrumb "#{competition}", (competition_path(competition) if can? :show, competition)
  end

  def add_to_competition_breadcrumb(competition)
    event = competition.event
    add_category_breadcrumb(event.category)
    add_competition_breadcrumb(competition)
  end

  def add_to_judge_breadcrumb(judge)
    add_to_competition_breadcrumb(judge.competition)
    add_breadcrumb judge, judge_scores_path(judge)
  end


end
