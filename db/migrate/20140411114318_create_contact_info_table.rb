class CreateContactInfoTable < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end
  class ContactDetail < ActiveRecord::Base
  end
  def change
    Registrant.reset_column_information

    create_table :contact_details do |t|
      t.integer :registrant_id
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country_residence
      t.string :country_representing

      t.string :phone
      t.string :mobile
      t.string :email
      t.string :club
      t.string :club_contact
      t.string :usa_member_number
      t.string :emergency_name
      t.string :emergency_relationship
      t.boolean :emergency_attending
      t.string :emergency_primary_phone
      t.string :emergency_other_phone
      t.string :responsible_adult_name
      t.string :responsible_adult_phone

      t.timestamps
    end

    ContactDetail.reset_column_information

    Registrant.all.each do |reg|
      cd = ContactDetail.new(
        registrant_id: reg.id,
        address: reg.address,
        city: reg.city,
        state: reg.state,
        zip: reg.zip,
        country_residence: reg.country_residence,
        country_representing: reg.country_representing,
        phone: reg.phone,
        mobile: reg.mobile,
        email: reg.email,
        club: reg.club,
        club_contact: reg.club_contact,
        usa_member_number: reg.usa_member_number,
        emergency_name: reg.emergency_name,
        emergency_relationship: reg.emergency_relationship,
        emergency_attending: reg.emergency_attending,
        emergency_primary_phone: reg.emergency_primary_phone,
        emergency_other_phone: reg.emergency_other_phone,
        responsible_adult_name: reg.responsible_adult_name,
        responsible_adult_phone: reg.responsible_adult_phone
      )
      cd.save!
    end
  end
end
