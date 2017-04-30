require 'spec_helper'

describe Importers::RecordCreators::PreliminaryExternalResult do
  def create_competitor(competition, bib_number)
    competitor = FactoryGirl.create(:event_competitor, competition: competition)
    reg = competitor.members.first.registrant
    reg.update_attribute(:bib_number, bib_number)
  end

  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:ranked_competition) }
  let(:creator) { described_class.new(competition, admin_user) }

  let(:row) do
    {
      bib_number: "101",
      points: "1.2",
      details: nil,
      status: "active"
    }
  end

  it "can process external result csv file" do
    create_competitor(competition, 101)

    expect do
      expect(creator.save(row, nil)).to be_truthy
    end.to change(ExternalResult, :count).by(1)
  end
end
