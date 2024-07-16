require 'spec_helper'

describe TimeParser do
  let(:parser) { described_class.new(time) }

  describe "with a time with thousands" do
    let(:time) { "23.123" }

    it "returns the correct thousands" do
      expect(parser.result[:thousands]).to eq(123)
    end
  end

  describe "with only hundreds" do
    let(:time) { "23.12" }

    it "returns the correct thousands" do
      expect(parser.result[:thousands]).to eq(120)
    end
  end

  describe "with only tens" do
    let(:time) { "23.1" }

    it "returns the correct thousands" do
      expect(parser.result[:thousands]).to eq(100)
    end
  end
end
