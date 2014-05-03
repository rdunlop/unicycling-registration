# == Schema Information
#
# Table name: combined_competitions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe CombinedCompetition do
  let(:combined_competition) { FactoryGirl.build_stubbed(:combined_competition) }

  it "requires a name" do
    expect(combined_competition).to be_valid
  end
end
