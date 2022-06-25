require 'spec_helper'

describe JudgeTypePresenter do
  let(:presenter) { described_class.new(judge_type) }

  describe "#total_header_words" do
    describe "with 2017 judge_type" do
      let(:judge_type) { FactoryBot.create(:judge_type, event_class: "Artistic Freestyle IUF 2017") }

      it "has total_header_words with Total Points" do
        expect(presenter.total_header_words.join(" ")).to eq("Total Points")
      end
    end

    describe "with 2019 judge_type" do
      let(:judge_type) { FactoryBot.create(:judge_type, event_class: "Artistic Freestyle IUF 2019") }

      it "has total_header_words with Avg Perc" do
        expect(presenter.total_header_words.join(" ")).to eq("Avg. Perc.")
      end
    end
  end
end
