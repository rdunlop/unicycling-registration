class MassEmailer
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def send_emails
    if email_form.valid?
      set_of_addresses = email_form.filtered_combined_emails
      first_index = 0
      current_set = set_of_addresses.slice(first_index, 30)
      until current_set == [] or current_set.nil?
        Notifications.delay.send_mass_email(email_form, current_set)
        first_index += 30
        current_set = set_of_addresses.slice(first_index, 30)
      end
      true
    else
      false
    end
  end

  def email_form
    @email_form ||= Email.new(params[:email])
  end
end
