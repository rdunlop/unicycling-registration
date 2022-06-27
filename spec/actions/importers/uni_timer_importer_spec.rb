require 'spec_helper'

describe Importers::UniTimerImporter do
  let(:admin_user) { FactoryBot.create(:super_admin_user) }
  let(:competition) { FactoryBot.create(:timed_competition, uses_lane_assignments: true) }
  let(:importer) { described_class.new(competition, admin_user) }

  let(:test_file) { fixture_path + '/uni_timer_start.csv' }
  let(:sample_input) { Rack::Test::UploadedFile.new(test_file, "text/plain") }

  let(:processor) {  Importers::Parsers::UniTimer.new(sample_input) }

  it "can process uni_timer file" do
    expect do
      expect(importer.process(true, processor)).to be_truthy
    end.to change(ImportResult, :count).by(2)
  end
end
