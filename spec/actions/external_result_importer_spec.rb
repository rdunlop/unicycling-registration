require 'spec_helper'

describe ExternalResultImporter do
  def create_competitor(competition, bib_number)
    competitor = FactoryGirl.create(:event_competitor, competition: competition)
    reg = competitor.members.first.registrant
    reg.update_attribute(:bib_number, bib_number)
  end

  let(:admin_user) { FactoryGirl.create(:super_admin_user) }
  let(:competition) { FactoryGirl.create(:ranked_competition) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:test_file) { fixture_path + '/external_results.csv' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  it "can process external result csv file" do
    create_competitor(competition, 101)
    create_competitor(competition, 102)
    create_competitor(competition, 103)
    create_competitor(competition, 104)

    expect do
      expect(importer.process_csv(sample_input)).to be_truthy
    end.to change(ExternalResult, :count).by(4)
    expect(importer.num_rows_processed).to eq(4)
  end
end
