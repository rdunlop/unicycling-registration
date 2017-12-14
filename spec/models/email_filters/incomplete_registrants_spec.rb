require 'spec_helper'

describe EmailFilters::IncompleteRegistrants do
  describe "with a registrant which hasn't finished their registration" do
    let!(:incomplete_registrant) { FactoryGirl.create(:competitor, status: "contact_details") }
    let!(:complete_registrant) { FactoryGirl.create(:competitor) }

    it "can include the email in a category-search email" do
      @filter = described_class.new
      expect(@filter.filtered_user_emails).to match_array([incomplete_registrant.user.email])
    end
  end
end
