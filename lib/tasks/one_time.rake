namespace :one_time do
  desc "Migrate from ContactDetail to OrganizationMembership"
  task migrate_memberships: :environment do
    puts "Migrating Organization Memberships from ContactDetail..."
    ContactDetail.includes(:registrant).all.find_each do |contact_detail|
      registrant = contact_detail.registrant
      if contact_detail.organization_member_number.present? ||
         contact_detail.organization_membership_manually_confirmed? ||
         contact_detail.organization_membership_system_confirmed?
        organization_membership = registrant.create_organization_membership_record
        organization_membership.legacy_member_number = contact_detail.organization_member_number
        organization_membership.manual_member_number = contact_detail.organization_member_number
        organization_membership.manually_confirmed = contact_detail.manually_confirmed

        organization_membership.system_confirmed = contact_detail.system_confirmed
        organization_membership.system_status = contact_detail.system_status
        organization_membership.updated_at = contact_detail.updated_at
        organization_membership.save
      end
    end
    puts "Done"
  end
end
