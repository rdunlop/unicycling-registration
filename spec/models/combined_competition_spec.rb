# == Schema Information
#
# Table name: combined_competitions
#
#  id                            :integer          not null, primary key
#  name                          :string(255)
#  created_at                    :datetime
#  updated_at                    :datetime
#  use_age_group_places          :boolean          default(FALSE)
#  percentage_based_calculations :boolean          default(FALSE)
#
# Indexes
#
#  index_combined_competitions_on_name  (name) UNIQUE
#

require 'spec_helper'

describe CombinedCompetition do
  let(:combined_competition) { FactoryGirl.build_stubbed(:combined_competition) }

  it "requires a name" do
    expect(combined_competition).to be_valid
  end
end
