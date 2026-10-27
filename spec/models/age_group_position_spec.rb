require 'spec_helper'

describe AgeGroupPosition do
  let(:age_group_type) { FactoryBot.create(:age_group_type) }
  let(:competition) { FactoryBot.create(:timed_competition, age_group_type: age_group_type) }
  let!(:entry_1) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 0, end_age: 10) }
  let!(:entry_2) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 11, end_age: 20) }
  let!(:entry_3) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 21, end_age: 30) }
  let!(:entry_4) { FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 31, end_age: 40) }

  # reload, so that the age group type entries created above are loaded
  before { competition.reload }

  def combine(*age_groups)
    AgeGroupCombiner.new(competition).combine(*age_groups)
    competition.age_group_combinations.last
  end

  it "uses the age group type order by default" do
    expect(competition).not_to be_custom_age_group_order
    expect(competition.age_groups).to eq([entry_1, entry_2, entry_3, entry_4])
  end

  it "orders the age groups of the competition" do
    competition.move_age_group(entry_3, 0)

    expect(competition).to be_custom_age_group_order
    expect(competition.age_groups).to eq([entry_3, entry_1, entry_2, entry_4])
    expect(Competition.find(competition.id).age_groups).to eq([entry_3, entry_1, entry_2, entry_4])
  end

  it "does not modify the age group type, nor other competitions" do
    other_competition = FactoryBot.create(:timed_competition, age_group_type: age_group_type)

    competition.move_age_group(entry_4, 0)

    expect(entry_4.reload.position).to eq(4)
    expect(other_competition.reload.age_groups).to eq([entry_1, entry_2, entry_3, entry_4])
  end

  it "orders combinations" do
    combination = combine(entry_1, entry_2)

    competition.move_age_group(combination, 2)

    expect(competition.age_groups).to eq([entry_3, entry_4, combination])
  end

  it "does not order a combined entry on its own" do
    combine(entry_1, entry_2)

    expect { competition.move_age_group(entry_2, 0) }.to raise_error(ArgumentError)
  end

  it "places a new combination at the place of its first entry" do
    competition.move_age_group(entry_4, 0)
    combination = combine(entry_2, entry_3)

    expect(competition.age_groups).to eq([entry_4, entry_1, combination])
  end

  it "keeps the place of separated entries" do
    combination = combine(entry_1, entry_2)
    competition.move_age_group(combination, 2)

    AgeGroupCombiner.new(competition).separate(combination)

    expect(competition.age_groups).to eq([entry_3, entry_4, entry_1, entry_2])
  end

  it "places entries without a position last" do
    competition.move_age_group(entry_2, 0)
    entry_5 = FactoryBot.create(:age_group_entry, age_group_type: age_group_type, start_age: 41, end_age: 50)
    described_class.where(age_group_entry: entry_4).delete_all

    expect(competition.reload.age_groups).to eq([entry_2, entry_1, entry_3, entry_4, entry_5])
  end

  it "can use the age group type order again" do
    competition.move_age_group(entry_3, 0)

    competition.reset_age_group_order

    expect(competition).not_to be_custom_age_group_order
    expect(competition.age_groups).to eq([entry_1, entry_2, entry_3, entry_4])
  end

  it "is removed when the competition changes its age group type" do
    competition.move_age_group(entry_3, 0)

    competition.update!(age_group_type: FactoryBot.create(:age_group_type))

    expect(described_class.count).to eq(0)
  end

  it "is removed with its age group entry" do
    competition.move_age_group(entry_3, 0)

    expect { entry_3.destroy }.to change(described_class, :count).by(-1)
  end

  it "assigns heats in the competition order" do
    young_competitor = FactoryBot.create(:event_competitor, competition: competition)
    young_competitor.update_column(:age_group_entry_id, entry_1.id)
    old_competitor = FactoryBot.create(:event_competitor, competition: competition)
    old_competitor.update_column(:age_group_entry_id, entry_4.id)
    competition.move_age_group(entry_4, 0)

    HeatAssignmentCreator.new(competition.reload, HeatLaneCalculator.new(4)).perform

    expect(old_competitor.reload.lane_assignments.first.heat).to be < young_competitor.reload.lane_assignments.first.heat
  end
end
