require 'spec_helper'

describe CreatesCompetitionResultsPdf do
  let(:competition) { FactoryGirl.create(:competition) }
  let(:subject) { described_class.new(competition) }

  describe "publish!" do
    it "creates a new result" do
      expect do
        subject.publish!
      end.to change(CompetitionResult, :count).by(1)
    end

    context "with a freestyle competition" do
      let(:competition) { FactoryGirl.create(:competition, :freestyle_2017)}
      it "creates 2 new results" do
        expect do
          subject.publish!
        end.to change(CompetitionResult, :count).by(2)
      end
    end
  end

  describe "unpublish!" do
    context "with an existing system_managed result" do
      let!(:res) { FactoryGirl.create(:competition_result, competition: competition, system_managed: true) }

      it "removes the system competition_results" do
        expect do
          subject.unpublish!
        end.to change(CompetitionResult, :count).by(-1)
      end
    end

    context "with multiple system_managed results" do
      let!(:res) { FactoryGirl.create(:competition_result, competition: competition, system_managed: true) }
      let!(:res2) { FactoryGirl.create(:competition_result, competition: competition, system_managed: true) }

      it "removes both system competition_results" do
        expect do
          subject.unpublish!
        end.to change(CompetitionResult, :count).by(-2)
      end
    end
  end
end
