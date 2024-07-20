require 'spec_helper'

describe TimeRounder do
  context "when set to hundreds precision" do
    let(:lower_is_better) { true }
    let(:entry_format) { OpenStruct.new(hours?: false, thousands?: false, hundreds?: true, lower_is_better?: lower_is_better) }
    let(:result) { described_class.new(thousands, data_entry_format: entry_format) }

    context "with data in the thousands" do
      let(:thousands) { 123 }

      context "when data_entry says that slower is better" do
        let(:lower_is_better) { true }

        it "rounds to the higher hundreds" do
          expect(result.rounded_thousands).to eq(130)
        end
      end

      context "when data_entry says that faster is better" do
        let(:lower_is_better) { false }

        it "rounds to the lower hundreds" do
          expect(result.rounded_thousands).to eq(120)
        end
      end
    end

    context "when given minutes, seconds and thousands" do
      let(:thousands) { (5 * 60 * 1000) + (31 * 1000) + 345 }
      let(:lower_is_better) { true }
      let(:entry_format) { OpenStruct.new(hours?: false, thousands?: false, hundreds?: true, lower_is_better?: lower_is_better) }
      let(:result) { described_class.new(thousands, data_entry_format: entry_format) }

      it "returns the minutes and seconds and rounded thousands" do
        expect(result.rounded_thousands).to eq((5 * 60 * 1000) + (31 * 1000) + 350)
      end
    end
  end

  context "when set to tens precision" do
    let(:lower_is_better) { true }
    let(:entry_format) { OpenStruct.new(hours?: false, thousands?: false, hundreds?: false, tens?: true, lower_is_better?: lower_is_better) }
    let(:result) { described_class.new(thousands, data_entry_format: entry_format) }

    context "with data in the thousands" do
      let(:thousands) { 123 }

      context "when data_entry says that slower is better" do
        let(:lower_is_better) { true }

        it "rounds to the higher tens" do
          expect(result.rounded_thousands).to eq(200)
        end
      end

      context "when data_entry says that faster is better" do
        let(:lower_is_better) { false }

        it "rounds to the lower tens" do
          expect(result.rounded_thousands).to eq(100)
        end
      end
    end
  end
end
