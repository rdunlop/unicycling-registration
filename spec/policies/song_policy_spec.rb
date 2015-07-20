require "spec_helper"

describe SongPolicy do
  let(:my_user) { FactoryGirl.create(:user)}
  let(:my_song) { FactoryGirl.create(:song, user: my_user) }

  subject { described_class }

  permissions :update? do
    let(:music_end_date) { 2.weeks.from_now }
    let(:config) { FactoryGirl.create(:event_configuration, music_submission_end_date: music_end_date) }
    let(:user) { my_user }
    let(:reg_closed?) { false }
    let(:authorized_laptop?) { false }
    let(:user_context) { UserContext.new(user, config, reg_closed?, authorized_laptop?) }

    it "can update my own song" do
      expect(subject).to permit(user_context, my_song)
    end

    it "cannot update another person's song" do
      other_song = FactoryGirl.create(:song)
      expect(subject).not_to permit(user_context, other_song)
    end

    describe "when the music_submission_date has passed" do
      let(:music_end_date) { 1.week.ago }

      it "cannot update music" do
        expect(subject).not_to permit(user_context, my_song)
      end

      describe "as a super admin" do
        let(:user) { FactoryGirl.create(:super_admin_user) }

        it "can update music" do
          expect(subject).to permit(user_context, my_song)
        end
      end
    end
  end
end
