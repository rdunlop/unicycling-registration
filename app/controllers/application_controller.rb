class ApplicationController < ActionController::Base
  include ApplicationHelper
  include EventsHelper
  include Pundit

  protect_from_forgery
  before_action :set_paper_trail_whodunnit
  before_action :load_config_object_and_i18n
  before_action :set_locale
  before_action :load_tenant

  before_action :set_home_breadcrumb, unless: :rails_admin_controller?

  # after_action :verify_authorized, :except => :index
  after_action :verify_authorized, unless: [:devise_controller?, :rails_admin_controller?]

  before_action :skip_authorization, if: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # a true rails_admin_controller? method was removed from rails_admin:
  # https://github.com/sferik/rails_admin/issues/2268
  def rails_admin_controller?
    (self.class.to_s =~ /RailsAdmin::/) == 0
  end

  # Override the default pundit_user so that we can pass additional state to the policies
  def pundit_user
    @pundit_user ||= UserContext.new(
      current_user,
      EventConfiguration.singleton,
      EventConfiguration.closed?,
      allow_reg_modifications?,
      translation_domain?
    )
  end

  # Is this domain marked as the Translations Domain
  # NOTE: This logic is duplicated in tolk.rb initializer
  def translation_domain?
    @tenant.try(:subdomain) == Rails.application.secrets.translations_subdomain
  end

  # so that devise routes are properly including the locale
  # https://github.com/plataformatec/devise/wiki/How-To:--Redirect-with-locale-after-authentication-failure
  def self.default_url_options(options = {})
    options.merge(locale: I18n.locale)
  end

  # so that all routes have the locale specified
  def default_url_options(_options = {})
    { locale: I18n.locale }
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def load_tenant
    return if Apartment::Tenant.current == "public"

    @tenant = Tenant.find_by(subdomain: Apartment::Tenant.current)
    if @tenant.nil?
      redirect_to tenants_path, flash: { alert: "Invalid subdomain" }
    end
  end

  def default_footer
    {left: '[date] [time]', center: @config.short_name, right: 'Page [page] of [topage]'}
  end

  def render_common_pdf(view_name, orientation = "Portrait", attachment = false, simple_pdf: false)
    if attachment
      disposition = "attachment"
    else
      disposition = "inline"
    end

    layout_html = simple_pdf ? "simple_pdf.html.haml" : "pdf.html.haml"

    render pdf: view_name,
           page_size: "Letter",
           print_media_type: true,
           margin: {top: 15, bottom: 10, left: 7, right: 7},
           show_as_html: params[:debug].present?,
           footer: default_footer,
           formats: [:pdf, :html],
           orientation: orientation,
           disposition: disposition,
           layout: layout_html
  end

  # a prototype, not working (currently cutting off lines)
  # NOT IN USE
  def render_pdf_with_header(view_name, template, locals)
    render pdf: view_name,
           page_size: "Letter",
           print_media_type: true,
           margin: {top: 60, left: 2, right: 2},
           show_as_html: params[:debug].present?,
           footer: default_footer,
           formats: [:html],
           header: { html: {template: template, locals: locals}},
           orientation: "Portrait",
           disposition: "inline",
           layout: "pdf.html"
  end

  # Prawn-Labels font setting
  def set_font(pdf)
    pdf.font_families.update("OpenSans" => {
                               normal: "#{Rails.root}/app/assets/fonts/OpenSans-Regular.ttf",
                               italic: "#{Rails.root}/app/assets/fonts/OpenSans-Italic.ttf",
                               bold: "#{Rails.root}/app/assets/fonts/OpenSans-Bold.ttf",
                               bold_italic: "#{Rails.root}/app/assets/fonts/OpenSans-BoldItalic.ttf"
                             })
    pdf.font "OpenSans"
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    if rails_admin_controller?
      redirect_to(request.referrer || "/")
    else
      redirect_to(request.referrer || root_path)
    end
  end

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
    set_i18n_available_locales
    I18n.locale = locale_parameter || locale_from_user || locale_from_headers || I18n.default_locale
  end

  def set_home_breadcrumb
    add_breadcrumb t("home", scope: "breadcrumbs"), proc { root_path }
  end

  def add_registrant_breadcrumb(registrant)
    add_breadcrumb "##{registrant.bib_number} - #{registrant}", registrant_path(registrant)
  end

  def add_payment_summary_breadcrumb
    add_breadcrumb "Payments Summary", summary_payments_path
  end

  def add_category_breadcrumb(category)
    add_breadcrumb category.to_s
  end

  def add_competition_breadcrumb(competition)
    add_breadcrumb competition.to_s, (competition_path(competition) if policy(competition).show?)
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
