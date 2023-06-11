# == Schema Information
#
# Table name: public.users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string
#  guest                  :boolean          default(FALSE), not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'spec_helper'

describe User do
  before do
    @user = FactoryBot.create(:user, password: "base_password", password_confirmation: "base_password")
  end

  it "can be created by factory girl" do
    expect(@user.valid?).to eq(true)
  end

  it "can specify a custom name" do
    expect(@user.to_s).to eq(@user.email)
    @user.name = "Robin"
    expect(@user.to_s).to eq("Robin")
  end

  it "can sum the amount owing from all registrants" do
    expect(@user.total_owing).to eq(0.to_money)
  end

  describe "with an expense_item" do
    before do
      @rp = FactoryBot.create(:registration_cost, :competitor)
      @noncomp_reg_cost = FactoryBot.create(:registration_cost, :noncompetitor)
      ei = @noncomp_reg_cost.expense_items.first
      ei.update!(cost: 50)
    end

    it "calculates the cost of a competitor" do
      @comp = FactoryBot.create(:competitor, user: @user)
      expect(@user.total_owing).to eq(100.to_money)
    end

    it "calculates the cost of a noncompetitor" do
      @comp = FactoryBot.create(:noncompetitor, user: @user)
      expect(@user.total_owing).to eq(50.to_money)
    end
  end

  describe "with related registrants" do
    before do
      @reg1 = FactoryBot.create(:competitor, user: @user)
      @reg2 = FactoryBot.create(:noncompetitor, user: @user)
      @reg3 = FactoryBot.create(:competitor, user: @user)

      @reg1.first_name = "holly"
      @reg1.save
    end

    describe "only users with registrants" do
      before do
        @other_user = FactoryBot.create(:user)
      end

      it "lists only users who have registrants" do
        expect(described_class.all_with_registrants).to eq([@user])
      end

      it "does not list users who only have deleted registrants" do
        FactoryBot.create(:registrant, deleted: true)
        expect(described_class.all_with_registrants).to eq([@user])
      end

      it "lists those users in unpaid_reg_fees" do
        expect(described_class.unpaid_reg_fees).to eq([@user])
      end
    end

    describe "with a user who is not confirmed" do
      before do
        u = FactoryBot.create(:user)
        u.confirmed_at = nil
        u.save!
      end

      it "does not list the non-confirmed user" do
        expect(described_class.confirmed).to eq([@user])
      end
    end

    it "orders the registrants by bib_number" do
      # @reg2, being a non-competitor, is a higher bib_number than the other two compeittors
      expect(@user.registrants.active).to eq([@reg1, @reg3, @reg2])
    end
  end

  describe "with 3 users" do
    before do
      @b = FactoryBot.create(:user, email: "b@b.com")
      @a = FactoryBot.create(:payment_admin, email: "a@a.com")
      @c = FactoryBot.create(:super_admin_user, email: "c@c.com")
    end

    it "lists them in alphabetical order" do
      expect(described_class.all).to eq([@a, @b, @c, @user])
    end
  end

  context "with user_convention" do
    let(:encrypted_password) { Devise::Encryptor.digest(described_class, "legacy_password") }
    let(:subdomain) { Apartment::Tenant.current }
    let!(:user_convention) do
      FactoryBot.create(:user_convention,
                        user: @user,
                        legacy_encrypted_password: encrypted_password,
                        subdomain: subdomain)
    end

    it "is NOT valid with legacy password" do
      expect(@user).not_to be_valid_password("legacy_password")
    end

    it "is valid with original password" do
      expect(@user).to be_valid_password("base_password")
    end

    it "does not allow blank password" do
      expect(@user).not_to be_valid_password(nil)
    end

    context "when the only sign in is for a different subdomain" do
      let(:subdomain) { "other" }

      it "is NOT valid with legacy password" do
        expect(@user).not_to be_valid_password("legacy_password")
      end
    end

    context "when the user_convention has no legacy password" do
      let!(:user_convention) { FactoryBot.create(:user_convention, user: @user, legacy_encrypted_password: nil) }

      it "does not allow blank password" do
        expect(@user).not_to be_valid_password(nil)
      end
    end
  end
end
