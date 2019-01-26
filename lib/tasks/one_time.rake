namespace :one_time do
  desc "Migrate from ContactDetail to OrganizationMembership"
  task migrate_memberships: :environment do
    Apartment.tenant_names.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        puts "for #{tenant}"
        puts "Migrating Organization Memberships from ContactDetail..."
        ContactDetail.includes(:registrant).all.find_each do |contact_detail|
          registrant = contact_detail.registrant
          if contact_detail.organization_member_number.present? ||
             contact_detail.organization_membership_manually_confirmed? ||
             contact_detail.organization_membership_system_confirmed?
            organization_membership = registrant.create_organization_membership_record
            organization_membership.manual_member_number = contact_detail.organization_member_number
            organization_membership.manually_confirmed = contact_detail.organization_membership_manually_confirmed

            organization_membership.system_confirmed = contact_detail.organization_membership_system_confirmed
            organization_membership.system_status = contact_detail.organization_membership_system_status
            organization_membership.updated_at = contact_detail.updated_at
            organization_membership.save
          end
        end
        puts "Done"
      end
    end
  end
end
