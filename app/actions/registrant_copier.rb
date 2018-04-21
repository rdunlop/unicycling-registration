# copy registrants from previous Conventions
class RegistrantCopier
  attr_accessor :subdomain, :previous_id, :registrant_type

  # Should be inverse of the splitter in the initializer
  def self.build_key(subdomain, registrant_id)
    "#{subdomain}/#{registrant_id}"
  end

  def initialize(registrant_source_string, registrant_type)
    @subdomain, @previous_id = registrant_source_string.split("/")
    @registrant_type = registrant_type
  end

  def registrant
    @registrant ||= Registrant.new(previous_registrant_attributes)
    @registrant.registrant_type = registrant_type
    @registrant
  end

  def contact_detail
    ContactDetail.new(previous_contact_detail_attributes) if previous_contact_detail_attributes.any?
  end

  private

  def previous_registrant_attributes
    attributes = {}
    Apartment::Tenant.switch(subdomain) do
      previous_reg = Registrant.find(previous_id)
      attributes = {
        first_name: previous_reg.first_name,
        middle_initial: previous_reg.middle_initial,
        last_name: previous_reg.last_name,
        birthday: previous_reg.birthday,
        gender: previous_reg.gender
      }
    end
  end

  def previous_contact_detail_attributes
    contact_attributes = {}
    Apartment::Tenant.switch(subdomain) do
      previous_reg = Registrant.find(previous_id)
      if previous_reg.contact_detail.present?
        contact_detail = previous_reg.contact_detail
        %i[address
           city
           state_code
           zip
           country_residence
           country_representing
           phone
           mobile
           email
           club
           club_contact
           organization_member_number].each do |attribute|
          contact_attributes[attribute] = contact_detail.send(attribute)
        end
      end
    end
    contact_attributes
  end
end
