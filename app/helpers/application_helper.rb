module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include LanguageHelper

  def setup_registrant_choices(registrant)
    EventChoice.all.each do |ec|
      if registrant.registrant_choices.where({:event_choice_id => ec.id}).empty?
        registrant.registrant_choices.build(event_choice_id: ec.id)
      end
    end
    Event.all.each do |ev|
      if registrant.registrant_event_sign_ups.select { |resu| resu.event_id == ev.id}.empty?
        registrant.registrant_event_sign_ups.build(event: ev)
      end
    end
    registrant
  end

  def mixpanel?
    !ENV['MIXPANEL_TOKEN'].nil?
  end

  def numeric?(val)
    Float(val) != nil rescue false
  end

  def print_formatted_currency(cost)
    # print in :en locale so that it is '$'
    number_to_currency(cost, format: EventConfiguration.singleton.currency, locale: :en)
  end

  def print_item_cost_currency(cost)
    return "Free" if cost == 0
    number_to_currency(cost, format: EventConfiguration.singleton.currency, locale: :en)
  end

  def text_to_html_linebreaks(text)
    start_tag = '<p>'
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
end
