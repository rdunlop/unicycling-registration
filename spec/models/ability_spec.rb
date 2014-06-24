require "cancan/matchers"
require "spec_helper"

describe "Ability" do
  describe "as a normal user" do
    before(:each) do
      @user = FactoryGirl.build_stubbed(:user)
      @config = FactoryGirl.create(:event_configuration, music_submission_end_date: Date.today + 3.days)
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

      describe "when the computer is authorized to modify reg" do
        subject { @ability = Ability.new(@user, true) }

        it { should be_able_to(:create, Registrant) }
      end
    end

    describe "when standard_skill is closed" do
      before(:each) do
        @config.update_attribute(:standard_skill_closed_date, 10.days.ago)
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
      it { should_not be_able_to(:review_heat, @competition) }
      it { should_not be_able_to(:approve_heat, @competition) }

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
          competitor = FactoryGirl.create(:event_competitor, competition: @competition)
          @score = FactoryGirl.create(:score, :judge => @judge, competitor: competitor)
          @other_score = FactoryGirl.create(:score, :competitor => @score.competitor) # different judge user
        end

        it { should be_able_to(:update, @score) }
        it { should_not be_able_to(:update, @other_score) }
        it { should_not be_able_to(:read, @other_score) }

        describe "when the competition is locked" do
          before(:each) do
            @competition.locked = true
            @competition.save!
            @score.reload
          end

          it { should_not be_able_to(:update, @score) }
        end
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

    describe "when the event is unlocked" do
      it { should be_able_to(:sort, @competition) }
      it { should be_able_to(:sort_random, @competition) }
      it { should be_able_to(:lock, @competition) }
      it { should be_able_to(:manage, ImportResult) }
      it { should be_able_to(:create, Judge) }
    end

    describe "when the event is locked" do
      before :each do
        @competition.update_attribute(:locked, true)
      end
      it { should_not be_able_to(:sort, @competition) }
      it { should_not be_able_to(:sort_random, @competition) }
      it { should_not be_able_to(:lock, @competition) }
      it { should_not be_able_to(:create, Judge.new(competition: @competition)) }
      it { should be_able_to(:read, @competition) }
    end

    it { should be_able_to(:read, @competition) }
    it { should_not be_able_to(:read, @competition.event) }
    it { should be_able_to(:export_scores, @competition) }
    it { should_not be_able_to(:edit, @competition) }
    it { should be_able_to(:create, DataEntryVolunteer) }
    it { should be_able_to(:summary, Event) }

    describe "with an event not under my direct direction" do
      let(:other_event_category) { FactoryGirl.create(:event).event_categories.first }
      it { should be_able_to(:sign_ups, other_event_category) }
    end

    it { should be_able_to(:create_race_official, :permission) }

    describe "with an associated judge to my event" do
      before(:each) do
        @judge = FactoryGirl.create(:judge, :competition => @competition)
      end
      it { should be_able_to(:destroy, @judge) }
      it { should be_able_to(:create, Judge) }
      it { should be_able_to(:show, @judge) }
      it { should be_able_to(:read, Score) }

      describe "When the judge has a score" do
        before :each do
          @score = FactoryGirl.create(:score, :judge => @judge)
        end

        it { should_not be_able_to(:destroy, @judge) }
        it { should be_able_to(:show, @judge) }
      end
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

  describe "When not logged in" do
    before :each do
      @competition = FactoryGirl.create(:competition)
    end
    subject { @ability = Ability.new(nil) }

    it { should be_able_to(:index, :result) }
    it { should be_able_to(:read, CombinedCompetition) }
    it { should be_able_to(:announcer, @competition) }

    describe "when a competition has published age_group_entry results" do
      before :each do
        @entry = FactoryGirl.create(:age_group_entry)
        @published_entry = @competition.published_age_group_entries.create(age_group_entry: @entry)
      end

      it { should be_able_to :show, @published_entry}
    end
  end
end
