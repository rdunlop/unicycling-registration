require "cancan/matchers"
require "spec_helper"

describe "Ability" do
  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.build_stubbed(:user)
      ENV["ONSITE_REGISTRATION"] = nil
      allow(EventConfiguration).to receive(:music_submission_ended?).and_return(false)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:read, @user) }
    it { should_not be_able_to(:read, User.new) }
    it { should be_able_to(:create, StandardSkillRoutine) }

    describe "with Additional Registrant Accesses" do
      before(:each) do
        @ara = FactoryGirl.create(:additional_registrant_access, :user => @user, :accepted_readonly => true)
        @ara_to_me = FactoryGirl.create(:additional_registrant_access, :registrant => FactoryGirl.create(:registrant, :user => @user))
        @ara_to_other = FactoryGirl.create(:additional_registrant_access)
      end
      it { should be_able_to(:read, @ara) }
      it { should be_able_to(:create, @ara) }
      it { should be_able_to(:new, @ara) }
      it { should be_able_to(:invitations, AdditionalRegistrantAccess) }
      it { should be_able_to(:read, @ara.registrant) }
      it { should_not be_able_to(:read_contact_info, @ara.registrant) }

      it { should be_able_to(:decline, @ara_to_me) }
      it { should be_able_to(:accept_readonly, @ara_to_me) }

      it { should_not be_able_to(:read, FactoryGirl.create(:additional_registrant_access)) }
      it { should_not be_able_to(:decline, @ara_to_other) }
      it { should_not be_able_to(:accept_readonly, @ara_to_other) }
    end

    describe "with a registration" do
      let(:registration) { FactoryGirl.build_stubbed(:registrant, :user => @user) }
      before(:each) do
        allow(@user).to receive(:registrants).and_return([registration])
      end

      it { should be_able_to(:read, registration) }
      it { should be_able_to(:read_contact_info, registration) }
      it { should be_able_to(:all, registration) }
      it { should be_able_to(:waiver, registration) }
      it { should be_able_to(:empty_waiver, Registrant) }
      it { should be_able_to(:index, RegistrantExpenseItem) }
      it { should be_able_to(:index, Song) }

      describe "with songs" do
        let(:song1) { FactoryGirl.build_stubbed(:song, :registrant => registration) }
        let(:song2) { FactoryGirl.build_stubbed(:song, :registrant => FactoryGirl.build_stubbed(:registrant)) }
        before(:each) do
          allow(registration).to receive(:songs).and_return([song1])
        end

        describe "can edit his own song" do
          it { should be_able_to(:edit, song1) }
          it { should be_able_to(:update, song1) }
          it { should be_able_to(:add_file, song1) }
          it { should be_able_to(:file_complete, song1) }
          it { should be_able_to(:destroy, song1) }
        end

        describe "cannot edit another user's song" do
          it { should_not be_able_to(:edit, song2)  }
          it { should_not be_able_to(:update, song2)  }
          it { should_not be_able_to(:destroy, song2)  }
        end
      end
      describe "with a StandardSkillRoutine" do
        before(:each) do
          @routine = FactoryGirl.create(:standard_skill_routine, :registrant => registration)
        end

        it { should be_able_to(:destroy, @routine) }
      end

      describe "with a required expense_item" do
        before(:each) do
          eg = FactoryGirl.create(:expense_group, :competitor_required => true)
          @ei = FactoryGirl.create(:expense_item, :expense_group => eg)
        end

        it { should_not be_able_to(:destroy, registration.registrant_expense_items.first) }
      end
    end

    describe "With a payment" do
      let(:payment) { FactoryGirl.create(:payment, :user => @user) }

      it { should be_able_to(:read, payment) }
    end

    describe "when registration is closed" do
      before(:each) do
        FactoryGirl.create(:registration_period, :onsite => false, :end_date => 10.days.ago)
      end

      it { should_not be_able_to(:create, Registrant) }

      describe "when the ONSITE flag is set" do
        before(:each) do
          ENV['ONSITE_REGISTRATION'] = "true"
        end
        after(:each) do
          ENV['ONSITE_REGISTRATION'] = nil
        end

        it { should be_able_to(:create, Registrant) }
      end
    end
    describe "when standard_skill is closed" do
      before(:each) do
        FactoryGirl.create(:event_configuration, :standard_skill_closed_date => 10.days.ago)
      end

      it { should_not be_able_to(:manage, StandardSkillRoutine) }
      it { should_not be_able_to(:manage, StandardSkillRoutineEntry) }
    end
  end

  describe "as an admin" do
    before(:each) do
      @user = FactoryGirl.create(:admin_user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:read, Registrant) }
    it { should be_able_to(:manage, Competitor) }

    it { should be_able_to(:manage_all, Registrant) }

    describe "with another user having a registrant" do
      let(:registration) { FactoryGirl.create(:registrant) }
      it { should be_able_to(:read, registration) }
      it { should be_able_to(:crud, registration) }
    end

    describe "with an rei" do
      let(:rei) { FactoryGirl.create(:registrant_expense_item) }
      it { should be_able_to(:index, RegistrantExpenseItem) }
      it { should be_able_to(:create, rei) }
      it { should be_able_to(:destroy, rei) }
    end
    describe "when registration is closed" do
      before(:each) do
        FactoryGirl.create(:registration_period, :onsite => false, :end_date => 10.days.ago)
      end

      it { should be_able_to(:create, Registrant) }
      it { should be_able_to(:manage, StandardSkillRoutine) }
      it { should be_able_to(:manage, StandardSkillRoutineEntry) }
    end
    describe "With a payment for another user" do
      let(:payment) { FactoryGirl.create(:payment) }

      it { should be_able_to(:read, payment) }
    end
    it { should be_able_to(:create_director, Judge) }
    it { should be_able_to(:create, Judge) }
  end

  describe "as a super_admin" do
    before(:each) do
      @user = FactoryGirl.create(:super_admin_user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:access, :rails_admin) }
  end

  describe "as a data_entry_volunteer" do
    before(:each) do
      @user = FactoryGirl.create(:data_entry_volunteer_user)
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:create, Score) }

    describe "with a Competition" do
      before(:each) do
        @competition = FactoryGirl.create(:competition)
      end
      it { should be_able_to(:create_scores, @competition) }
      it { should be_able_to(:read, Competitor) }
      it { should_not be_able_to(:sort, @competition) }
      it { should_not be_able_to(:sort_random, @competition) }

      describe "when the Competition is locked" do
        before(:each) do
          @competition.locked = true
          @competition.save!
        end

        it { should_not be_able_to(:create_scores, @competition) }
      end
      describe "with a score" do
        before(:each) do
          @judge = FactoryGirl.create(:judge, :user => @user, :competition => @competition)
          @score = FactoryGirl.create(:score, :judge => @judge)
          @other_score = FactoryGirl.create(:score, :competitor => @score.competitor) # different judge user
        end

        it { should be_able_to(:update, @score) }
        it { should_not be_able_to(:update, @other_score) }
        it { should_not be_able_to(:read, @other_score) }
      end
    end
  end

  describe "as a director" do
    before(:each) do
      @competition = FactoryGirl.create(:competition)
      @event_category = @competition.event.event_categories.first
      @competition.save!
      @user = FactoryGirl.create(:user)
      @user.add_role :director, @competition.event
      @user.add_role :data_entry_volunteer
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:distance_attempts, @competition) }
    it { should be_able_to(:freestyle_scores, @competition) }
    it { should be_able_to(:export_scores, @competition) }
    it { should be_able_to(:set_places, @competition) }
    it { should be_able_to(:sort, @competition) }
    it { should be_able_to(:sort_random, @competition) }
    it { should be_able_to(:lock, @competition) }
    it { should_not be_able_to(:edit, @competition) }
    it { should be_able_to(:create, DataEntryVolunteer) }
    it { should be_able_to(:manage, DistanceAttempt) }

    it { should be_able_to(:sign_ups, @event_category) }
    it { should be_able_to(:create, Judge) }

    describe "with an associated judge to my event" do
      before(:each) do
        @judge = FactoryGirl.create(:judge, :competition => @competition)
      end
      it { should be_able_to(:destroy, @judge) }
      it { should be_able_to(:create, Judge) }
    end
  end

  describe "as event_planner"  do
    before(:each) do
      @competition = FactoryGirl.create(:competition)
      @event_category = @competition.event.event_categories.first
      @user = FactoryGirl.create(:user)
      @user.add_role :event_planner
    end
    subject { @ability = Ability.new(@user) }

    it { should be_able_to(:summary, Event) }
    it { should be_able_to(:sign_ups, @event_category) }
  end

end
