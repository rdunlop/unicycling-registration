class EventConfiguration < ActiveRecord::Base
  attr_accessible :artistic_closed_date, :closed, :contact_email, :currency, :dates_description, :event_url, :location, :logo_image, :long_name, :short_name, :standard_skill_closed_date, :start_date, :tshirt_closed_date

  validates :short_name, :presence => true
  validates :long_name, :presence => true
  validates :event_url, :format => URI::regexp(%w(http https)), :unless => "event_url.nil?"

  def logo_image=(input_data)
    self.logo_filename = input_data.original_filename
    self.logo_type = input_data.content_type.chomp
    self.logo_binary = input_data.read
  end
end
