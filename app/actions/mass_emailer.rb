class MassEmailer
  attr_reader :subject, :body, :addresses

  def initialize(subject, body, addresses)
    @subject = subject
    @body = body
    @addresses = addresses
  end

  def send_emails
    first_index = 0
    current_set = addresses.slice(first_index, 30)

    until current_set == [] || current_set.nil?
      Notifications.send_mass_email(subject, body, current_set).deliver_later
      first_index += 30
      current_set = addresses.slice(first_index, 30)
    end
  end
end
