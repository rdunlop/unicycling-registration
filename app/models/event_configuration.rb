class EventConfiguration < ActiveRecord::Base
  attr_accessible :artistic_closed_date, :closed, :contact_email, :currency, :dates_description, :event_url, :location, :logo_image, :long_name, :short_name, :standard_skill_closed_date, :start_date, :tshirt_closed_date, :test_mode, :waiver_url

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

    if ENV['PAYPAL_TEST'].nil? or ENV['PAYPAL_TEST'] == "true"
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

  def self.short_name
    ec = EventConfiguration.first
    if ec.nil?
      ""
    else
      ec.short_name
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

  def self.start_date
    ec = EventConfiguration.first
    if ec.nil?
      nil
    else
      ec.start_date
    end
  end

  def self.waiver_url
    ec = EventConfiguration.first
    if ec.nil? or ec.waiver_url.nil? or  ec.waiver_url.empty?
      nil
    else
      ec.waiver_url
    end
  end

  def self.configuration_exists?
    !EventConfiguration.first.nil?
  end

  def self.event_url
    ec = EventConfiguration.first
    if ec.nil? or ec.event_url.nil? or  ec.event_url.empty?
      nil
    else
      ec.event_url
    end
  end

  def as_json(options={})
    super(:except => [:logo_binary, :logo_type, :logo_filename])
  end

  def self.closed?
    ec = EventConfiguration.first
    unless ec.nil?
      ec.closed
    else
      false
    end
  end

end
