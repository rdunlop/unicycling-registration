# == Schema Information
#
# Table name: contact_details
#
#  id                                         :integer          not null, primary key
#  registrant_id                              :integer
#  address                                    :string
#  city                                       :string
#  state_code                                 :string
#  zip                                        :string
#  country_residence                          :string
#  country_representing                       :string
#  phone                                      :string
#  mobile                                     :string
#  email                                      :string
#  club                                       :string
#  club_contact                               :string
#  organization_member_number                 :string
#  emergency_name                             :string
#  emergency_relationship                     :string
#  emergency_attending                        :boolean          default(FALSE), not null
#  emergency_primary_phone                    :string
#  emergency_other_phone                      :string
#  responsible_adult_name                     :string
#  responsible_adult_phone                    :string
#  created_at                                 :datetime
#  updated_at                                 :datetime
#  organization_membership_manually_confirmed :boolean          default(FALSE), not null
#  birthplace                                 :string
#  italian_fiscal_code                        :string
#  organization_membership_system_confirmed   :boolean          default(FALSE), not null
#  organization_membership_system_status      :string
#
# Indexes
#
#  index_contact_details_on_registrant_id  (registrant_id) UNIQUE
#  index_contact_details_registrant_id     (registrant_id)
#

class ContactDetail < ApplicationRecord
  belongs_to :registrant, inverse_of: :contact_detail, touch: true

  # address block
  with_options if: -> { EventConfiguration.singleton.request_address? } do
    validates :address, :city, :country_residence, :zip, presence: true
    validates :state_code, presence: true, unless: -> { EventConfiguration.singleton.usa == false }
  end
  validates :birthplace, presence: true, if: -> { EventConfiguration.singleton.italian_requirements? }
  validates :italian_fiscal_code, format: { with: /\A[a-zA-Z]{6}[0-9]{2}[a-zA-Z][0-9]{2}[a-zA-Z][0-9]{3}[a-zA-Z]\Z/, message: "must be specified if you are from Italy" }, if: :vat_required?

  # contact-info block
  with_options if: -> { EventConfiguration.singleton.request_emergency_contact? } do
    validates :emergency_name, :emergency_relationship, :emergency_primary_phone, presence: true
  end

  with_options if: :minor? do
    validates :responsible_adult_name, :responsible_adult_phone, presence: true
  end

  validates :email, presence: true

  after_save :update_usa_membership_status, if: proc { EventConfiguration.singleton.organization_membership_usa? }

  delegate :minor?, to: :registrant, allow_nil: true

  # Italians are required to enter VAT_Number and Birthplace
  def vat_required?
    EventConfiguration.singleton.italian_requirements? && country_residence == "IT"
  end

  def country_code
    country_representing.presence || country_residence
  end

  def country
    return "N/A" if country_code.nil?

    country = ISO3166::Country[country_code]
    country.translations[I18n.locale.to_s] || country.name
  end

  # Display the state, based on the country_residence
  def state
    country = ISO3166::Country[country_residence]
    if country.try(:subdivisions?)
      country.subdivisions[state_code.to_sym].try(:[], "name")
    else
      state_code
    end
  end

  # is this registrant a member of the relevant unicycling federation?
  def organization_membership_confirmed?
    organization_membership_system_confirmed? || organization_membership_manually_confirmed?
  end

  private

  def update_usa_membership_status
    return unless organization_member_number_changed?

    # If we perform the search immediately, sometimes the ContactDetail hasn't been committed yet, so we wait 3 seconds.
    UpdateUsaMembershipStatusWorker.perform_in(3.seconds, registrant_id)
  end
end
