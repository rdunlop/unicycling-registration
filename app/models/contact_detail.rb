# == Schema Information
#
# Table name: contact_details
#
#  id                              :integer          not null, primary key
#  registrant_id                   :integer
#  address                         :string(255)
#  city                            :string(255)
#  state_code                      :string(255)
#  zip                             :string(255)
#  country_residence               :string(255)
#  country_representing            :string(255)
#  phone                           :string(255)
#  mobile                          :string(255)
#  email                           :string(255)
#  club                            :string(255)
#  club_contact                    :string(255)
#  usa_member_number               :string(255)
#  emergency_name                  :string(255)
#  emergency_relationship          :string(255)
#  emergency_attending             :boolean          default(FALSE), not null
#  emergency_primary_phone         :string(255)
#  emergency_other_phone           :string(255)
#  responsible_adult_name          :string(255)
#  responsible_adult_phone         :string(255)
#  created_at                      :datetime
#  updated_at                      :datetime
#  usa_confirmed_paid              :boolean          default(FALSE), not null
#  usa_family_membership_holder_id :integer
#  birthplace                      :string
#  italian_fiscal_code             :string
#
# Indexes
#
#  index_contact_details_on_registrant_id  (registrant_id) UNIQUE
#  index_contact_details_registrant_id     (registrant_id)
#

class ContactDetail < ActiveRecord::Base
  belongs_to :registrant, inverse_of: :contact_detail, touch: true
  belongs_to :usa_family_membership_holder, class_name: "Registrant"
  validates :address, :city, :country_residence, :zip, presence: true
  validates :state_code, presence: true, unless: "EventConfiguration.singleton.usa == false"

  # contact-info block
  validates :emergency_name, :emergency_relationship, :emergency_primary_phone, presence: true
  validates :responsible_adult_name, :responsible_adult_phone, presence: true, if: :minor?
  validates :birthplace, presence: true, if: "EventConfiguration.singleton.italian_requirements?"
  validates :italian_fiscal_code, format: { with: /\A[a-zA-Z]{6}[0-9]{2}[a-zA-Z][0-9]{2}[a-zA-Z][0-9]{3}[a-zA-Z]\Z/, message: "must be specified if you are from Italy" }, if: :vat_required?

  # Italians are required to enter VAT_Number and Birthplace
  def vat_required?
    EventConfiguration.singleton.italian_requirements? && country_residence == "IT"
  end

  def minor?
    registrant && !registrant.spectator? && registrant.age < 18
  end

  def country_code
    if country_representing.nil? || country_representing.empty?
      country_residence
    else
      country_representing
    end
  end

  def country
    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  # Display the state, based on the country_residence
  def state
    country = ISO3166::Country[country_residence]
    if country.try(:subdivisions?)
      country.subdivisions[state_code].try(:[], "name")
    else
      state_code
    end
  end
end
