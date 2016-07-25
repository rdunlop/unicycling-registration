require 'spec_helper'

RSpec.describe CompetitionHeatTsvZipCreator do
  let(:competition) { FactoryGirl.create(:competition) }
  before do
    # Heat 1
    create_competitor(competition, "123", 1, 1)
    create_competitor(competition, "122", 1, 2)
    create_competitor(competition, "133", 1, 3)
    # Heat 2
    create_competitor(competition, "223", 2, 1)
    create_competitor(competition, "222", 2, 2)
    create_competitor(competition, "233", 2, 3)
  end
  let(:subject) { described_class.new(payment.reload, coupon_code_string) }
  let(:do_action) { subject.perform }

  it "creates a zip" do
    described_class.new(competition).zip_file("myFile") do |zip_file|
      expect(zip_file).not_to be_nil
    end
  end
end
