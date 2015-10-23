module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include LanguageHelper

  def log(msg)
    Rails.logger.debug msg
  end

  def setup_registrant_choices(registrant)
    EventChoice.all.each do |ec|
      if registrant.registrant_choices.where(event_choice_id: ec.id).empty?
        registrant.registrant_choices.build(event_choice_id: ec.id)
      end
    end
    Event.all.each do |ev|
      if registrant.registrant_event_sign_ups.select { |resu| resu.event_id == ev.id}.empty?
        registrant.registrant_event_sign_ups.build(event: ev)
      end
      if ev.best_time? && registrant.registrant_best_times.select { |bt| bt.event_id == ev.id }.empty?
        registrant.registrant_best_times.build(event: ev)
      end
    end
    registrant
  end

  def numeric?(val)
    !Float(val).nil? rescue false
  end

  def print_formatted_currency(cost)
    ec = EventConfiguration.singleton
    number_to_currency(cost, format: ec.currency, unit: ec.currency_unit)
  end

  def print_item_cost_currency(cost)
    return "Free" if cost == 0
    print_formatted_currency(cost)
  end

  def print_time_until_prices_increase(reg_period)
    if EventConfiguration.singleton.online_payment?
      if DateTime.now > reg_period.end_date
        t("prices_increase_soon")
      else
        end_date = distance_of_time_in_words(DateTime.now, reg_period.last_day) + " (" + (l (reg_period.last_day), format: :short) + ")"
        t("prices_increase_at_date", end_date: end_date)
      end
    end
  end

  def text_to_html_linebreaks(text, add_class = nil)
    if add_class
      start_tag = "<p class=\"#{add_class}\">"
    else
      start_tag = '<p>'
    end
    text = text.to_s.dup
    text.gsub!(/\r?\n/, "\n")                     # \r\n and \r => \n
    text.gsub!(/\n\n+/, "</p>\n\n#{start_tag}")   # 2+ newline  => paragraph
    text.gsub!(/([^\n]\n)(?=[^\n])/, '\1<br />')  # 1 newline   => br
    text.insert 0, start_tag
    text << "</p>"
  end

  # Allow laptop to access Registration elements and update them (ignore the 'is closed')
  # allow laptop to create user accounts without e-mail confirmation, and auto-login.
  def allow_reg_modifications?
    cookies.signed[:user_permissions] == "yes"
  end

  # Disallow laptop (remove cookies)
  def set_reg_modifications_allowed(allow = true)
    if allow
      cookies.signed[:user_permissions] = {
        value: "yes",
        expires: 24.hours.from_now
      }
    else
      cookies.delete :user_permissions
    end
  end

  def modification_access_key(date = Date.today)
    hash = Digest::SHA256.hexdigest(date.to_s + Rails.application.secrets.secret_key_base + Apartment::Tenant.current)
    hash.to_i(16) % 1000000
  end

  def skip_user_creation_confirmation?
    override_by_env = Rails.application.secrets.mail_skip_confirmation
    override_by_env || allow_reg_modifications?
  end

  def new_locale_path(new_locale, existing_path = request.original_fullpath)
    current_locale_prefix = "/#{I18n.locale}/"
    if existing_path.starts_with?(current_locale_prefix)
      "/#{new_locale}/" + existing_path[current_locale_prefix.length..-1]
    else
      root_path(locale: new_locale)
    end
  end
end
