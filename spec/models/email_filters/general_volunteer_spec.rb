require 'spec_helper'

describe EmailFilters::GeneralVolunteer do
  describe "with a registrant who is volunteering" do
    before do
      @reg_volunteer = FactoryBot.create(:competitor, volunteer: true)
      @reg_not_volunteer = FactoryBot.create(:competitor, volunteer: false)
    end

    it "can create a list" do
      @filter = described_class.new
      expect(@filter.filtered_user_emails).to match_array([@reg_volunteer.user.email])
    end
  end
end
