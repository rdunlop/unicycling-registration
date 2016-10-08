# == Schema Information
#
# Table name: events
#
#  id                          :integer          not null, primary key
#  category_id                 :integer
#  position                    :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  name                        :string(255)
#  visible                     :boolean          default(TRUE), not null
#  accepts_music_uploads       :boolean          default(FALSE), not null
#  artistic                    :boolean          default(FALSE), not null
#  accepts_wheel_size_override :boolean          default(FALSE), not null
#  event_categories_count      :integer          default(0), not null
#  event_choices_count         :integer          default(0), not null
#  best_time_format            :string           default("none"), not null
#  standard_skill              :boolean          default(FALSE), not null
#
# Indexes
#
#  index_events_category_id                     (category_id)
#  index_events_on_accepts_wheel_size_override  (accepts_wheel_size_override)
#

require 'spec_helper'

describe EventsController do
  before do
    user = FactoryGirl.create(:super_admin_user)
    sign_in user
  end
  let(:event) { FactoryGirl.create(:event) }

  # This should return the minimal set of attributes required to create a valid
  # Event. As you add validations to Event, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {
      name: "Event Name"
    }
  end

  describe "as a normal user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    it "Cannot read summary" do
      get :summary
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET summary" do
    it "assigns all events as @events" do
      event
      get :summary
      expect(response).to be_success
      assert_select "td", event.event_categories.first.to_s
    end
    describe "With competitors and non-competitors" do
      before(:each) do
        @comp1 = FactoryGirl.create(:competitor)
        @comp2 = FactoryGirl.create(:competitor)
        @non_comp1 = FactoryGirl.create(:noncompetitor)
      end
      it "sets the number of registrants as @num_registrants" do
        get :summary
        assert_select "b.num_registrants", "3"
      end
      it "sets the number of competitors as @num_competitors" do
        get :summary
        assert_select ".num_competitors", "2"
      end
      it "sets the number of non_competitors as @num_noncompetitors" do
        get :summary
        assert_select ".num_noncompetitors", "1"
      end
    end
  end

  describe "GET general_volunteers" do
    it "returns all general volunteers" do
      get :general_volunteers
      expect(response).to be_success
    end
  end

  describe "GET specific_volunteers" do
    let(:volunteer_opportunity) { FactoryGirl.create(:volunteer_opportunity) }

    it "returns a list" do
      get :specific_volunteers, params: { volunteer_opportunity_id: volunteer_opportunity.id }
      expect(response).to be_success
    end
  end

  describe "GET sign_ups" do
    it "returns all sign ups" do
      get :sign_ups, params: { id: event.id }
      expect(response).to be_success
    end
  end
end
