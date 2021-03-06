# == Schema Information
#
# Table name: combined_competition_entries
#
#  id                      :integer          not null, primary key
#  combined_competition_id :integer
#  abbreviation            :string
#  tie_breaker             :boolean          default(FALSE), not null
#  points_1                :integer
#  points_2                :integer
#  points_3                :integer
#  points_4                :integer
#  points_5                :integer
#  points_6                :integer
#  points_7                :integer
#  points_8                :integer
#  points_9                :integer
#  points_10               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  competition_id          :integer
#  base_points             :integer
#  distance                :integer
#  points_11               :integer
#  points_12               :integer
#  points_13               :integer
#  points_14               :integer
#  points_15               :integer
#

require 'spec_helper'

describe CombinedCompetitionEntry do
  def build_competitor(overall_place)
    comp = FactoryBot.build_stubbed(:event_competitor)
    allow(comp).to receive(:overall_place).and_return(overall_place)
    allow(comp).to receive(:has_result?).and_return(true)
    allow(comp).to receive(:gender).and_return("Male")
    comp
  end

  let(:combined_competition_entry) { FactoryBot.build_stubbed(:combined_competition_entry) }

  it "is initially valid" do
    expect(combined_competition_entry).to be_valid
  end

  describe "requires base_points only when percentage based" do
    let(:combined_competition) { FactoryBot.build_stubbed :combined_competition, :percentage_based_calculations }

    it "requires base_ponints" do
      entry = FactoryBot.build :combined_competition_entry, combined_competition: combined_competition
      entry.base_points = nil
      expect(entry).to be_invalid
    end
  end
end
