class EventConfiguration < ActiveRecord::Base
  attr_accessible :artistic_closed_date, :closed, :contact_email, :currency, :dates_description, :event_url, :location, :logo_image, :long_name, :short_name, :standard_skill_closed_date, :start_date, :tshirt_closed_date, :test_mode

  validates :short_name, :presence => true
  validates :long_name, :presence => true
  validates :event_url, :format => URI::regexp(%w(http https)), :unless => "event_url.nil?"

  validates :test_mode, :inclusion => { :in => [true, false] } # because it's a boolean

  after_initialize :init

  def init
    self.test_mode = true if self.test_mode.nil?
  end

  def logo_image=(input_data)
    self.logo_filename = input_data.original_filename
    self.logo_type = input_data.content_type.chomp
    self.logo_binary = input_data.read
  end

  def self.paypal_base_url
    paypal_test_url = "https://www.sandbox.paypal.com"
    paypal_live_url = "https://www.paypal.com"

    ec = EventConfiguration.first
    if ec.nil? or ec.test_mode
      paypal_test_url
    else
      paypal_live_url
    end
  end

  def self.contact_email
    ec = EventConfiguration.first
    if ec.nil?
      ""
    else
      ec.contact_email
    end
  end

  def self.long_name
    ec = EventConfiguration.first
    if ec.nil?
      ""
    else
      ec.long_name
    end
  end
end
