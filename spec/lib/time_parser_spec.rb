require 'spec_helper'

describe TimeParser do
  context "valid times" do
    it "can read ss.hhh" do
      expect(described_class.new("23.123").result).to eq(
        minutes: 0,
        seconds: 23,
        thousands: 123
      )
    end

    it "can read hours minutes seconds thousands" do
      expect(described_class.new("2:04:40.123").result).to eq(
        minutes: 124,
        seconds: 40,
        thousands: 123
      )
    end

    it "can read minutes seconds thousands" do
      expect(described_class.new("24:40.123").result).to eq(
        minutes: 24,
        seconds: 40,
        thousands: 123
      )
    end

    it "can read hours minutes seconds tens" do
      expect(described_class.new("2:04:40.1").result).to eq(
        minutes: 124,
        seconds: 40,
        thousands: 100
      )
    end
  end

  context "invalid times" do
    it "returns nil" do
      expect(described_class.new("").result).to be_nil
    end
  end
end
