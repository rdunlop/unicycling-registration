# == Schema Information
#
# Table name: event_configurations
#
#  id                                    :integer          not null, primary key
#  short_name                            :string(255)
#  long_name                             :string(255)
#  location                              :string(255)
#  dates_description                     :string(255)
#  event_url                             :string(255)
#  start_date                            :date
#  logo_binary                           :binary
#  contact_email                         :string(255)
#  artistic_closed_date                  :date
#  standard_skill_closed_date            :date
#  tshirt_closed_date                    :date
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  logo_filename                         :string(255)
#  logo_type                             :string(255)
#  test_mode                             :boolean
#  waiver_url                            :string(255)
#  comp_noncomp_url                      :string(255)
#  has_print_waiver                      :boolean
#  standard_skill                        :boolean          default(FALSE)
#  usa                                   :boolean          default(FALSE)
#  iuf                                   :boolean          default(FALSE)
#  currency_code                         :string(255)
#  currency                              :text
#  rulebook_url                          :string(255)
#  style_name                            :string(255)
#  has_online_waiver                     :boolean
#  online_waiver_text                    :text
#  music_submission_end_date             :date
#  artistic_score_elimination_mode_naucc :boolean          default(TRUE)
#  usa_individual_expense_item_id        :integer
#  usa_family_expense_item_id            :integer
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
  validates :test_mode, :has_print_waiver, :has_online_waiver, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :artistic_score_elimination_mode_naucc, :inclusion => { :in => [true, false] } # because it's a boolean
  validates :usa, :iuf, :standard_skill, :inclusion => { :in => [true, false] } # because it's a boolean

  belongs_to :usa_individual_expense_item, :class_name => "ExpenseItem"
  belongs_to :usa_family_expense_item, :class_name => "ExpenseItem"

  validates :usa_individual_expense_item, :usa_family_expense_item, presence: { message: "Must be specified when enabling 'usa' mode"}, if: "self.usa"

  validates :standard_skill_closed_date, :presence => true, :unless => "standard_skill.nil? or standard_skill == false"

  after_initialize :init

  def init
    self.test_mode = true if self.test_mode.nil?
    self.has_print_waiver = false if self.has_print_waiver.nil?
    self.has_online_waiver = false if self.has_online_waiver.nil?
    self.usa = true if self.usa.nil?
    self.iuf = false if self.iuf.nil?
    self.standard_skill = true if self.standard_skill.nil?
    self.artistic_score_elimination_mode_naucc = true if self.artistic_score_elimination_mode_naucc.nil?
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
    get_attribute_or_return_value(:test_mode, true)
  end

  def self.contact_email
    get_attribute_or_return_value(:contact_email, "")
  end

  def self.short_name
    get_attribute_or_return_value(:short_name, "")
  end

  def self.long_name
    get_attribute_or_return_value(:long_name, "")
  end

  def self.style_name
    if ec.nil? or ec.style_name.blank?
      "naucc_2013"
    else
      ec.style_name
    end
  end

  def self.start_date
    get_attribute_or_return_value(:start_date, nil)
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
    if ec.nil? or ec.standard_skill.nil?
      true
    else
      ec.standard_skill
    end
  end

  def self.standard_skill_closed?(today = Date.today)
    if ec.nil?
      false
    else
      ec.standard_skill_closed_date <= today
    end
  end

  def self.music_submission_ended?(today = Date.today)
    if ec.nil? || ec.music_submission_end_date.nil?
      true
    else
      ec.music_submission_end_date <= today
    end
  end


  def self.waiver_url
    get_url(:waiver_url, nil)
  end

  def self.has_print_waiver
    if ec.nil? or ec.has_print_waiver.nil?
      false
    else
      ec.has_print_waiver
    end
  end

  def self.has_online_waiver
    if ec.nil? or ec.has_online_waiver.nil?
      false
    else
      ec.has_online_waiver
    end
  end

  def self.online_waiver_text
    if ec.nil? or ec.online_waiver_text.nil? or ec.online_waiver_text.empty?
      "This is where your online waiver text would go."
    else
      ec.online_waiver_text
    end
  end

  def self.usa
    if ec.nil? or ec.usa.nil?
      true
    else
      ec.usa
    end
  end

  def self.usa_individual_expense_item
    if ec.nil? or ec.usa_individual_expense_item.nil?
      nil
    else
      ec.usa_individual_expense_item
    end
  end

  def self.usa_family_expense_item
    if ec.nil? or ec.usa_family_expense_item.nil?
      nil
    else
      ec.usa_family_expense_item
    end
  end

  def self.iuf
    if ec.nil? or ec.iuf.nil?
      false
    else
      ec.iuf
    end
  end

  def self.rulebook_url
    get_url(:rulebook_url, nil)
  end

  def self.currency
    if ec.nil? or ec.currency.blank?
      "%u%n USD"
    else
      ec.currency
    end
  end

  def self.currency_code
    if ec.nil? or ec.currency_code.blank?
      "USD"
    else
      ec.currency_code
    end
  end

  def self.comp_noncomp_url
    get_url(:comp_noncomp_url, nil)
  end

  def self.configuration_exists?
    !ec.nil?
  end

  def self.event_url
    get_url(:event_url, nil)
  end

  def self.artistic_score_elimination_mode_naucc
    if ec.nil? or ec.artistic_score_elimination_mode_naucc.nil?
      true
    else
      ec.artistic_score_elimination_mode_naucc
    end
  end

  def as_json(options={})
    super(:except => [:logo_binary, :logo_type, :logo_filename])
  end

  private

  def self.get_attribute_or_return_value(attribute, default_value)
    if ec.nil?
      default_value
    else
      ec.send(attribute)
    end
  end

  def self.get_url(attribute, default_value)
    if ec.nil? or ec.send(attribute).nil? or  ec.send(attribute).empty?
      default_value
    else
      ec.send(attribute)
    end
  end

  private

  def self.ec
    @ec ||= EventConfiguration.first
  end
end
