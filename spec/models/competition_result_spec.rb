require 'spec_helper'

describe CompetitionResult do
  let(:competition) { FactoryGirl.create(:competition) }

  let(:competition_result) { FactoryGirl.build(:competition_result) }

  it "is valid from FactoryGirl" do
    expect(competition_result).to be_valid
  end

  context "with a custom name" do
    let(:competition_result) { FactoryGirl.build(:competition_result, system_managed: true, name: "Fun Results") }

    it "has a title of 'Fun Results'" do
      expect(competition_result.to_s).to eq("Fun Results")
    end
  end

  context "as system managed without a custom name" do
    let(:competition_result) { FactoryGirl.build(:competition_result, system_managed: true, name: nil) }

    it "has a title of 'Results'" do
      expect(competition_result.to_s).to eq("Results")
    end
  end
end

# == Schema Information
#
# Table name: competition_results
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  results_file   :string(255)
#  system_managed :boolean          default(FALSE), not null
#  published      :boolean          default(FALSE), not null
#  published_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#
