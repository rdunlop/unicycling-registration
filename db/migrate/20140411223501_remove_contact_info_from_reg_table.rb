class RemoveContactInfoFromRegTable < ActiveRecord::Migration
  class Registrant < ActiveRecord::Base
  end
  class ContactDetail < ActiveRecord::Base
    belongs_to :registrant
  end

  def up
    Registrant.reset_column_information

    change_table :registrants do |t|
      t.remove :address
      t.remove :city
      t.remove :state
      t.remove :zip
      t.remove :country_residence
      t.remove :country_representing

      t.remove :phone
      t.remove :mobile
      t.remove :email
      t.remove :club
      t.remove :club_contact
      t.remove :usa_member_number
      t.remove :emergency_name
      t.remove :emergency_relationship
      t.remove :emergency_attending
      t.remove :emergency_primary_phone
      t.remove :emergency_other_phone
      t.remove :responsible_adult_name
      t.remove :responsible_adult_phone
    end
  end

  def down
    ContactDetail.reset_column_information

    change_table :registrants do |t|
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
    end

    Registrant.reset_column_information

    ContactDetail.all.each do |cd|
      reg = cd.registrant
      reg.update_attributes(
        address: cd.address,
        city: cd.city,
        state: cd.state,
        zip: cd.zip,
        country_residence: cd.country_residence,
        country_representing: cd.country_representing,
        phone: cd.phone,
        mobile: cd.mobile,
        email: cd.email,
        club: cd.club,
        club_contact: cd.club_contact,
        usa_member_number: cd.usa_member_number,
        emergency_name: cd.emergency_name,
        emergency_relationship: cd.emergency_relationship,
        emergency_attending: cd.emergency_attending,
        emergency_primary_phone: cd.emergency_primary_phone,
        emergency_other_phone: cd.emergency_other_phone,
        responsible_adult_name: cd.responsible_adult_name,
        responsible_adult_phone: cd.responsible_adult_phone
      )
    end
  end
end
