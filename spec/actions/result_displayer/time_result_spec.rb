require "spec_helper"

RSpec.describe ResultDisplayer::TimeResult do
  let(:subject) { described_class.new(competition) }

  context "points competition" do
    let(:competition) { FactoryGirl.build(:high_points_competition) }
    let(:result) { FactoryGirl.build(:import_result, points: 3.45) }

    it "summary_headings" do
      expect(subject.summary_headings).to eq(["Points"])
    end

    it "summary_result_data" do
      expect(subject.summary_result_data(result)).to eq(["3.45"])
    end
  end

  context "times competition" do
    let(:competition) { FactoryGirl.build(:timed_competition) }
    let(:result) { FactoryGirl.build(:import_result, minutes: 1, seconds: 2, thousands: 345) }

    it "summary_headings" do
      expect(subject.summary_headings).to eq(["Time"])
    end

    it "summary_result_data" do
      expect(subject.summary_result_data(result)).to eq(["1:02.345"])
    end

    it "headings" do
      expect(subject.headings).to eq(["Minutes", "Seconds", "Thousands"])
    end

    it "result_data" do
      expect(subject.result_data(result)).to eq([1, 2, 345])
    end

    it "form_label_symbols" do
      expect(subject.form_label_symbols).to eq([:minutes, :seconds, :thousands])
    end

    it "form_inputs" do
      expect(subject.form_inputs).to eq([
                                          [:minutes, {min: 0}],
                                          [:seconds, {min: 0}],
                                          [:thousands, {min: 0}]
                                        ])
    end
  end

  context "times with laps competition" do
    let(:competition) { FactoryGirl.build(:timed_laps_competition) }
    let(:result) { FactoryGirl.build(:import_result, minutes: 1, seconds: 2, thousands: 345, number_of_laps: 3) }

    it "summary_headings" do
      expect(subject.summary_headings).to eq(["Time", "# Laps"])
    end

    it "summary_result_data" do
      expect(subject.summary_result_data(result)).to eq(["1:02.345", 3])
    end

    it "headings" do
      expect(subject.headings).to eq(["Minutes", "Seconds", "Thousands", "# Laps"])
    end

    it "result_data" do
      expect(subject.result_data(result)).to eq([1, 2, 345, 3])
    end

    it "form_label_symbols" do
      expect(subject.form_label_symbols).to eq([:minutes, :seconds, :thousands, :number_of_laps])
    end

    it "form_inputs" do
      expect(subject.form_inputs).to eq([
                                          [:minutes, {min: 0}],
                                          [:seconds, {min: 0}],
                                          [:thousands, {min: 0}],
                                          [:number_of_laps, {min: 1}]
                                        ])
    end
  end
end
