require "spec_helper"

describe RegistrantPolicy do
  let(:my_user) { FactoryGirl.create(:user)}
  let(:my_registrant) { FactoryGirl.create(:registrant, user: my_user) }
  let(:other_registrant) { FactoryGirl.create(:registrant) }

  let(:ara_readonly) { FactoryGirl.create(:additional_registrant_access, user: my_user, accepted_readonly: true) }
  let(:readonly_registrant) { ara_readonly.registrant }

  let(:ara_full_access) { FactoryGirl.create(:additional_registrant_access, user: my_user, accepted_readwrite: true) }
  let(:full_access_registrant) { ara_full_access.registrant }

  let(:unconfirmed_ara) { FactoryGirl.create(:additional_registrant_access, user: my_user) }
  let(:unconfirmed_shared_registrant) { unconfirmed_ara.registrant }

  subject { described_class }

  permissions :create? do
    let(:reg_closed?) { false }
    let(:authorized_laptop?) { false }
    let(:user) { my_user }
    let(:user_context) { UserContext.new(user, false, reg_closed?, authorized_laptop?) }

    describe "while registration is open" do
      it "allows creation" do
        expect(subject).to permit(user_context, my_registrant)
      end
    end

    describe "when registration is closed" do
      let(:reg_closed?) { true }

      describe "on a normal laptop" do
        it { expect(subject).not_to permit(user_context, my_registrant) }
      end

      describe "on an authorized laptop" do
        let(:authorized_laptop?) { true }

        it { expect(subject).to permit(user_context, my_registrant) }
      end

      describe "as a super_admin" do
        let(:user) { FactoryGirl.create(:super_admin_user) }

        it { expect(subject).to permit(user_context, my_registrant) }
      end
    end
  end

  permissions :show? do
    it "allows access to my own registrant" do
      expect(subject).to permit(my_user, my_registrant)
    end

    it "disallows access to another registrant" do
      expect(subject).to_not permit(FactoryGirl.create(:user), my_registrant)
    end

    it "allows access to another registrant if I have a additional access permit" do
      expect(subject).to permit(my_user, readonly_registrant)
      expect(subject).to permit(my_user, full_access_registrant)
    end

    it "disallows access to another registrant by me" do
      expect(subject).to_not permit(my_user, other_registrant)
    end

    it "doesn't allow access if not confirmed" do
      expect(subject).not_to permit(my_user, unconfirmed_shared_registrant)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryGirl.create(:super_admin_user), my_registrant)
    end
  end

  permissions :show_contact_details? do
    it "allows access to my own registrant" do
      expect(subject).to permit(my_user, my_registrant)
    end

    it "disallows access to another registrant" do
      expect(subject).to_not permit(FactoryGirl.create(:user), my_registrant)
    end

    it "doesn't allow access if readonly" do
      expect(subject).not_to permit(my_user, readonly_registrant)
    end

    it "allows access for readwrite" do
      expect(subject).to permit(my_user, full_access_registrant)
    end

    it "grants access to super_admin" do
      expect(subject).to permit(FactoryGirl.create(:super_admin_user), my_registrant)
    end
  end

  describe "within the wizard" do
    let(:reg_closed?) { false }
    let(:authorized_laptop?) { false }
    let(:user) { my_user }
    let(:event_sign_up_closed?) { false }
    let(:config) { double(event_sign_up_closed?: event_sign_up_closed?) }
    let(:user_context) { UserContext.new(user, config, reg_closed?, authorized_laptop?) }

    permissions :add_events? do
      describe "while registration is open" do
        describe "for a non-competitor" do
          it { expect(subject).not_to permit(user_context, FactoryGirl.create(:noncompetitor)) }
        end

        describe "for a competitor" do
          it { expect(subject).not_to permit(user_context, FactoryGirl.create(:noncompetitor)) }
        end
      end

      describe "when registration is closed" do
        let(:reg_closed?) { true }
        let(:event_sign_up_closed?) { true }

        describe "on a normal laptop" do
          it { expect(subject).not_to permit(user_context, my_registrant) }
        end

        describe "on an authorized laptop" do
          let(:authorized_laptop?) { true }

          it { expect(subject).not_to permit(user_context, my_registrant) }
        end

        describe "as a super_admin" do
          let(:user) { FactoryGirl.create(:super_admin_user) }

          it { expect(subject).to permit(user_context, my_registrant) }
        end
      end

      describe "when registration is closed, but event_sign_up is open" do
        let(:reg_closed?) { true }
        let(:event_sign_up_closed?) { false }

        describe "on a normal laptop" do
          it { expect(subject).to permit(user_context, my_registrant) }
        end

        describe "on an authorized laptop" do
          let(:authorized_laptop?) { true }

          it { expect(subject).to permit(user_context, my_registrant) }
        end

        describe "as a super_admin" do
          let(:user) { FactoryGirl.create(:super_admin_user) }

          it { expect(subject).to permit(user_context, my_registrant) }
        end
      end
    end

    permissions :set_wheel_sizes? do
      before do
        FactoryGirl.create(:event_configuration, start_date: Date.today)
      end

      describe "for an adult" do
        it { expect(subject).not_to permit(user_context, FactoryGirl.create(:minor_competitor, user: my_user, birthday: 11.years.ago)) }
      end

      describe "for a child" do
        it { expect(subject).to permit(user_context, FactoryGirl.create(:minor_competitor, user: my_user, birthday: 8.years.ago)) }
      end
    end
  end
end
