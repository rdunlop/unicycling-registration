require 'spec_helper'

describe GlobalUserMigrator do
  context "without an existing global user" do
    let!(:user) { GlobalUserMigrator::User.create!(email: "bob@example.com", encrypted_password: "test") }
    before do
      described_class.new("testing").update_global_users
    end

    it "creates a global_user record" do
      expect(GlobalUserMigrator::GlobalUser.count).to eq(1)
    end

    it "creates a user_conventions record" do
      expect(GlobalUserMigrator::UserConvention.count).to eq(1)
    end

    it "does not create a new User record" do
      expect(GlobalUserMigrator::User.count).to eq(1)
    end

    it "sets the global_user record with the correct information", :aggregate_failures do
      global_user = GlobalUserMigrator::GlobalUser.first
      attributes = user.attributes.reject{|key, _| key == "id" }
      attributes.keys.each do |attribute|
        expect(global_user.send(attribute)).to eq(user.send(attribute))
      end
    end
  end

  context "with an existing global user" do
    let(:ga_email) { user.email }
    let(:ga_encrypted_password) { "ga_encrypted_password"}
    let(:ga_reset_password_token) { "ga_reset_password_token" }
    let(:ga_reset_password_sent_at) { }
    let(:ga_remember_created_at) { }
    let(:ga_sign_in_count) { }
    let(:ga_current_sign_in_at) { }
    let(:ga_last_sign_in_at) { }
    let(:ga_current_sign_in_ip) { }
    let(:ga_last_sign_in_ip) { }
    let(:ga_confirmation_token) { }
    let(:ga_confirmed_at) { }
    let(:ga_confirmation_sent_at) { }
    let(:ga_name) { }
    let(:ga_guest) { false }
    let(:ga_created_at) { 1.day.ago }
    let(:ga_updated_at) { DateTime.now }

    before do
      GlobalUserMigrator::GlobalUser.create!(
        email: ga_email,
        encrypted_password: ga_encrypted_password,
        reset_password_token: ga_reset_password_token,
        reset_password_sent_at: ga_reset_password_sent_at,
        remember_created_at: ga_remember_created_at,
        sign_in_count: ga_sign_in_count,
        current_sign_in_at: ga_current_sign_in_at,
        last_sign_in_at: ga_last_sign_in_at,
        current_sign_in_ip: ga_current_sign_in_ip,
        last_sign_in_ip: ga_last_sign_in_ip,
        confirmation_token: ga_confirmation_token,
        confirmed_at: ga_confirmed_at,
        confirmation_sent_at: ga_confirmation_sent_at,
        created_at: ga_created_at,
        updated_at: ga_updated_at,
        name: ga_name,
        guest: ga_guest)
      described_class.new("testing").update_global_users
    end
    context "without a fully-specified user record" do
      let!(:user) { GlobalUserMigrator::User.create!(email: "bob@example.com", encrypted_password: "test") }

      it "does not create another global user" do
        expect(GlobalUserMigrator::GlobalUser.count).to eq(1)
      end

      it "creates a user_conventions record" do
        expect(GlobalUserMigrator::UserConvention.count).to eq(1)
      end
    end

    context "with a fully-specified user record" do
      let(:original_sign_in_count) { 5 }
      let!(:user) do
        GlobalUserMigrator::User.create!(
          email: "bob@example.com",
          encrypted_password: "user_password",
          current_sign_in_at: 1.day.ago,
          current_sign_in_ip: "1.2.3.4",
          sign_in_count: original_sign_in_count,
          last_sign_in_at: 1.day.ago,
          last_sign_in_ip: "2.3.4.5",
          created_at: 3.days.ago,
          updated_at: 2.days.ago,
          reset_password_sent_at: 1.day.ago,
          reset_password_token: "my_token",
          confirmation_sent_at: 1.day.ago,
          confirmed_at: 1.day.ago,
          confirmation_token: "conf_token",
          remember_created_at: 1.day.ago,
          name: "User_Name",
          guest: "User Guest"
        )
      end

      context "when the global_user does not have any competing attributes" do
        xit "updates the global_user attributes" do
        end
      end

      context "when the global_user has WORSE attributes at every turn" do
        let(:ga_reset_password_token) { "ga_reset_password_token" }
        let(:ga_reset_password_sent_at) { DateTime.now - 10.days }
        let(:ga_remember_created_at) { DateTime.now - 10.days }
        let(:ga_sign_in_count) { 10 }
        let(:ga_current_sign_in_at) { DateTime.now - 10.days }
        let(:ga_last_sign_in_at) { DateTime.now - 10.days }
        let(:ga_current_sign_in_ip) { "4.4.4.4" }
        let(:ga_last_sign_in_ip) { "3.3.3.3" }
        let(:ga_confirmation_token) { "ga_token" }
        let(:ga_confirmed_at) { DateTime.now }
        let(:ga_confirmation_sent_at) { DateTime.now - 10.days }
        let(:ga_name) { "" }

        it "does not update the global_user attributes", :aggregate_failures do
          global_user = GlobalUserMigrator::GlobalUser.first
          expect(global_user.encrypted_password).not_to eq(ga_encrypted_password)
          expect(global_user.reset_password_token).not_to eq(ga_reset_password_token)
          expect(global_user.reset_password_sent_at).not_to eq(ga_reset_password_sent_at)
          expect(global_user.remember_created_at).not_to eq(ga_remember_created_at)
          expect(global_user.sign_in_count).not_to eq(ga_sign_in_count)
          expect(global_user.current_sign_in_at).not_to eq(ga_current_sign_in_at)
          expect(global_user.last_sign_in_at).not_to eq(ga_last_sign_in_at)
          expect(global_user.current_sign_in_ip).not_to eq(ga_current_sign_in_ip)
          expect(global_user.last_sign_in_ip).not_to eq(ga_last_sign_in_ip)
          expect(global_user.confirmation_token).not_to eq(ga_confirmation_token)
          expect(global_user.confirmed_at).not_to eq(ga_confirmed_at)
          expect(global_user.confirmation_sent_at).not_to match_microseconds(ga_confirmation_sent_at)
          expect(global_user.created_at).not_to eq(ga_created_at)
          # activerecord overwrites this
          # expect(global_user.updated_at).not_to eq(ga_updated_at)
          expect(global_user.name).not_to eq(ga_name)
          # guest doesn't change
          # expect(global_user.guest).not_to eq(ga_guest)
        end
      end

      context "when the global_user has BETTER attributes at every turn" do
        let(:ga_reset_password_token) { "ga_reset_password_token" }
        let(:ga_reset_password_sent_at) { DateTime.now }
        let(:ga_remember_created_at) { DateTime.now }
        let(:ga_sign_in_count) { 10 }
        let(:ga_current_sign_in_at) { DateTime.now }
        let(:ga_last_sign_in_at) { DateTime.now }
        let(:ga_current_sign_in_ip) { "4.4.4.4" }
        let(:ga_last_sign_in_ip) { "3.3.3.3" }
        let(:ga_confirmation_token) { "ga_token" }
        let(:ga_confirmed_at) { 10.days.ago }
        let(:ga_confirmation_sent_at) { DateTime.now }
        let(:ga_name) { "ga_name" }
        let(:ga_guest) { false }
        let(:ga_created_at) { 10.days.ago }

        it "does not update the global_user attributes" do
          global_user = GlobalUserMigrator::GlobalUser.first
          expect(global_user.encrypted_password).to eq(ga_encrypted_password)
          expect(global_user.reset_password_token).to eq(ga_reset_password_token)
          expect(global_user.reset_password_sent_at).to eq(ga_reset_password_sent_at)
          expect(global_user.remember_created_at).to eq(ga_remember_created_at)
          expect(global_user.sign_in_count).to eq(original_sign_in_count + ga_sign_in_count)
          expect(global_user.current_sign_in_at).to eq(ga_current_sign_in_at)
          expect(global_user.last_sign_in_at).to eq(ga_last_sign_in_at)
          expect(global_user.current_sign_in_ip).to eq(ga_current_sign_in_ip)
          expect(global_user.last_sign_in_ip).to eq(ga_last_sign_in_ip)
          expect(global_user.confirmation_token).to eq(ga_confirmation_token)
          expect(global_user.confirmed_at).to eq(ga_confirmed_at)
          expect(global_user.confirmation_sent_at).to eq(ga_confirmation_sent_at)
          expect(global_user.created_at).to eq(ga_created_at)
          # activerecord overwrites this
          # expect(global_user.updated_at).to eq(ga_updated_at)
          expect(global_user.name).to eq(ga_name)
          expect(global_user.guest).to eq(ga_guest)
        end
      end
    end
  end

  context "with multiple users in multiple tenants" do
    let(:new_tenant_subdomain) { "testing2" }
    before do
      tenant = Tenant.create!(description: 'Another Tenant', subdomain: new_tenant_subdomain, admin_upgrade_code: "TEST_UPGRADE_CODE")
      Apartment::Tenant.create(tenant.subdomain)
      Apartment::Tenant.switch new_tenant_subdomain do
        20.times do |i|
          GlobalUserMigrator::User.create(
            email: "test#{i}@example.com",
            encrypted_password: "password"
          )
        end
      end
    end

    after do
      begin
        Apartment::Tenant.drop(new_tenant_subdomain)
      rescue
        nil
      end
    end

    it "can determine the maximum User.id" do
      expect(described_class.maximum_user_id).to eq(20)
    end
  end

  context "after setting the start_user_id" do
    before do
      described_class.set_global_start_user_id(200)
    end

    it "creates new global_user records from that number" do
      global_user = GlobalUserMigrator::GlobalUser.create!(
        email: "bob@example.com",
        encrypted_password: "user_password")
      expect(global_user.id).to eq(201)
    end
  end

  describe "#migrate_user_ids" do
    let!(:user) do
      GlobalUserMigrator::User.create!(
        email: "bob@example.com",
        encrypted_password: "user_password")
    end
    before do
      described_class.set_global_start_user_id(200)

      # create global_user and user_convention records
      described_class.new("testing").update_global_users
    end

    context "with existing additional_registrant_accesses" do
      let!(:ara) { FactoryGirl.create(:additional_registrant_access, user: user) }

      it "changes the ara user_id" do
        described_class.new("testing").migrate_user_ids
        global_user = GlobalUserMigrator::GlobalUser.first

        expect(ara.reload.user_id).to eq(global_user.id)
      end
    end
  end
end
