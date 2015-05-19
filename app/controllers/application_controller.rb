class ApplicationController < ActionController::Base
  include ApplicationHelper
  include EventsHelper

  before_action :load_config_object
  before_action :set_locale
  before_action :load_tenant

  before_action :set_home_breadcrumb, unless: :rails_admin_controller?

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

  rescue_from CanCan::AccessDenied do |exception|
    Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    redirect_to root_path, :alert => exception.message
  end

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  def load_config_object
    @config = EventConfiguration.singleton
    I18n.available_locales = EventConfiguration.all_available_languages & @config.enabled_locales
    set_fallbacks
  end

  def set_fallbacks
    fallbacks_hash = {}
    I18n.available_locales.each do |locale|
      fallbacks_hash[locale] = [locale, *(I18n.available_locales - [locale])]
    end
    Globalize.fallbacks = fallbacks_hash
  end

  def load_tenant
    @tenant = Tenant.find_by(subdomain: Apartment::Tenant.current_tenant) || public_tenant
  end

  def public_tenant
    Tenant.new subdomain: 'public'
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

  def locale_parameter
    params[:locale] if I18n.available_locales.include?(params[:locale].try(:to_sym))
  end

  def locale_from_user
    nil
  end

  def locale_from_headers
    http_accept_language.compatible_language_from(I18n.available_locales)
  end

  def set_locale
    I18n.locale = locale_parameter || locale_from_user || locale_from_headers || I18n.default_locale
  end

  def set_home_breadcrumb
    add_breadcrumb t("home", scope: "breadcrumbs"), Proc.new { root_path }
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

  def add_competition_setup_breadcrumb
    add_breadcrumb "Competitions", competition_setup_path
  end
end
