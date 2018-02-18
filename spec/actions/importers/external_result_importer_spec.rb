require 'spec_helper'

describe Importers::ExternalResultImporter do
  def create_competitor(competition, bib_number)
    competitor = FactoryBot.create(:event_competitor, competition: competition)
    reg = competitor.members.first.registrant
    reg.update_attribute(:bib_number, bib_number)
  end

  let(:admin_user) { FactoryBot.create(:super_admin_user) }
  let(:competition) { FactoryBot.create(:ranked_competition) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:processor) do
    double(
      file_contents: ["a line"],
      valid_file?: true,
      process_row: {
        bib_number: "101",
        points: "1.2",
        details: nil,
        status: "active"
      }
    )
  end

  it "can process external result csv file" do
    create_competitor(competition, 101)

    expect do
      expect(importer.process(processor)).to be_truthy
    end.to change(ExternalResult, :count).by(1)
    expect(importer.num_rows_processed).to eq(1)
  end

  it "Can process external result when registrant does not exist" do
    expect do
      expect(importer.process(processor)).to be_falsy
    end.to change(ExternalResult, :count).by(0)
    expect(importer.num_rows_processed).to eq(0)
    expect(importer.errors).to eq("Unable to find registrant ({:bib_number=>\"101\", :points=>\"1.2\", :details=>nil, :status=>\"active\"})")
  end
end
