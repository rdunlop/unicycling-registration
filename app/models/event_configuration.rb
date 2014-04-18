# == Schema Information
#
# Table name: event_configurations
#
#  id                         :integer          not null, primary key
#  short_name                 :string(255)
#  long_name                  :string(255)
#  location                   :string(255)
#  dates_description          :string(255)
#  event_url                  :string(255)
#  start_date                 :date
#  logo_binary                :binary
#  contact_email              :string(255)
#  artistic_closed_date       :date
#  standard_skill_closed_date :date
#  tshirt_closed_date         :date
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  logo_filename              :string(255)
#  logo_type                  :string(255)
#  test_mode                  :boolean
#  waiver_url                 :string(255)
#  comp_noncomp_url           :string(255)
#  has_print_waiver           :boolean
#  standard_skill             :boolean          default(FALSE)
#  usa                        :boolean          default(FALSE)
#  iuf                        :boolean          default(FALSE)
#  currency_code              :string(255)
#  currency                   :text
#  rulebook_url               :string(255)
#  style_name                 :string(255)
#  has_online_waiver          :boolean
#  online_waiver_text         :text
#  music_submission_end_date  :date
#

class EventConfiguration < ActiveRecord::Base
  translates :short_name, :long_name, :location, :dates_description
  accepts_nested_attributes_for :translations

  validates :short_name, :long_name, :presence => true
  validates :event_url, :format => URI::regexp(%w(http https)), :unless => "event_url.nil?"
  validates :comp_noncomp_url, :format => URI::regexp(%w(http https)), :unless => "comp_noncomp_url.nil? or comp_noncomp_url.empty?"

  def self.style_names
    ["unicon_17", "naucc_2013", "naucc_2014"]
  end

  validates :style_name, :inclusion => {:in => self.style_names, :allow_blank => true }
  validates :test_mode, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :has_print_waiver, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :has_online_waiver, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :usa, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :iuf, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :standard_skill, :inclusion => { :in => [true, false] } # because it's a boolean

  validates :standard_skill_closed_date, :presence => true, :unless => "standard_skill.nil? or standard_skill == false"

  after_initialize :init

  def init
    self.test_mode = true if self.test_mode.nil?
    self.has_print_waiver = false if self.has_print_waiver.nil?
    self.has_online_waiver = false if self.has_online_waiver.nil?
    self.usa = true if self.usa.nil?
    self.iuf = false if self.iuf.nil?
    self.standard_skill = true if self.standard_skill.nil?
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

  def self.test_mode
    ec = EventConfiguration.first
    if ec.nil?
      true
    else
      ec.test_mode
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

  def self.style_name
    ec = EventConfiguration.first
    if ec.nil? or ec.style_name.blank?
      "naucc_2013"
    else
      ec.style_name
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

  def self.closed_date
    last_online_rp = RegistrationPeriod.last_online_period
    last_online_rp.end_date unless last_online_rp.nil?
  end

  def self.closed?(today = Date.today)
    last_online_rp = RegistrationPeriod.last_online_period

    if last_online_rp.nil?
      false
    else
      last_online_rp.last_day < today
    end
  end

  def self.standard_skill
    ec = EventConfiguration.first
    if ec.nil? or ec.standard_skill.nil?
      true
    else
      ec.standard_skill
    end
  end

  def self.standard_skill_closed?(today = Date.today)
    ec = EventConfiguration.first
    if ec.nil?
      false
    else
      ec.standard_skill_closed_date <= today
    end
  end

  def self.music_submission_ended?(today = Date.today)
    ec = EventConfiguration.first
    if ec.nil? || ec.music_submission_end_date.nil?
      true
    else
      ec.music_submission_end_date <= today
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

  def self.has_print_waiver
    ec = EventConfiguration.first
    if ec.nil? or ec.has_print_waiver.nil?
      false
    else
      ec.has_print_waiver
    end
  end

  def self.has_online_waiver
    ec = EventConfiguration.first
    if ec.nil? or ec.has_online_waiver.nil?
      false
    else
      ec.has_online_waiver
    end
  end

  def self.online_waiver_text
    ec = EventConfiguration.first
    if ec.nil? or ec.online_waiver_text.nil? or ec.online_waiver_text.empty?
      "This is where your online waiver text would go."
    else
      ec.online_waiver_text
    end
  end

  def self.usa
    ec = EventConfiguration.first
    if ec.nil? or ec.usa.nil?
      true
    else
      ec.usa
    end
  end

  def self.iuf
    ec = EventConfiguration.first
    if ec.nil? or ec.iuf.nil?
      false
    else
      ec.iuf
    end
  end

  def self.rulebook_url
    ec = EventConfiguration.first
    if ec.nil? or ec.rulebook_url.nil? or  ec.rulebook_url.empty?
      nil
    else
      ec.rulebook_url
    end
  end

  def self.currency
    ec = EventConfiguration.first
    if ec.nil? or ec.currency.blank?
      "%u%n USD"
    else
      ec.currency
    end
  end

  def self.currency_code
    ec = EventConfiguration.first
    if ec.nil? or ec.currency_code.blank?
      "USD"
    else
      ec.currency_code
    end
  end


  def self.comp_noncomp_url
    ec = EventConfiguration.first
    if ec.nil? or ec.comp_noncomp_url.nil? or  ec.comp_noncomp_url.empty?
      nil
    else
      ec.comp_noncomp_url
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

end
