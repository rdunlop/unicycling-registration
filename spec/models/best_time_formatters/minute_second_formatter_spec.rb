# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean          default(FALSE), not null
#  event_category_id :integer
#  created_at        :datetime
#  updated_at        :datetime
#  event_id          :integer
#
# Indexes
#
#  index_registrant_event_sign_ups_event_category_id              (event_category_id)
#  index_registrant_event_sign_ups_event_id                       (event_id)
#  index_registrant_event_sign_ups_on_registrant_id_and_event_id  (registrant_id,event_id) UNIQUE
#  index_registrant_event_sign_ups_registrant_id                  (registrant_id)
#

require 'spec_helper'

describe BestTimeFormatter::MinuteSecondFormatter do
  it "converts one minute to hundreds" do
    expect(described_class.from_string("1:00.00")).to eq(6000)
  end

  it "converts hundreds" do
    expect(described_class.from_string("0:00.59")).to eq(59)
  end

  it "converts full case" do
    expect(described_class.from_string("1:23.45")).to eq(8345)
  end

  it "allows full case with double-digit minutes" do
    expect(described_class).to be_valid("10:23.45")
  end

  it "allows hour/minute only" do
    expect(described_class).to be_valid("1:30")
  end

  it "requires that minutes be specified" do
    expect(described_class).not_to be_valid("30")
  end

  it "requires hours be specified" do
    expect(described_class).not_to be_valid("30.12")
  end

  it "doesn't allow seconds/hundreds only" do
    expect(described_class).not_to be_valid("0.10")
  end

  it "converts 6000 to 1 minute" do
    expect(described_class.to_string(6000)).to eq("1:00.00")
  end

  it "converts 62345 to 10 minutes" do
    expect(described_class.to_string(60001)).to eq("10:00.01")
  end

  it "converts tens of seconds to hundreds" do
    expect(described_class.from_string("0:00.1")).to eq(10)
  end

  it "allows 00:15.50" do
    expect(described_class).to be_valid("00:15.50")
    expect(described_class.to_string(described_class.from_string("00:15.50"))).to eq("0:15.50")
    expect(described_class).to be_valid("0:15.50")
  end

  it "marks empty as invalid" do
    expect(described_class).not_to be_valid("")
  end

  it "marks real string as valid" do
    expect(described_class).to be_valid("1:00.00")
  end

  it "doesnt't allow seconds over 59" do
    expect(described_class).not_to be_valid("0:60")
  end

  it "doesn't allow negative minutes" do
    expect(described_class).not_to be_valid("-1:0")
  end

  it "allows minutes greater than 60" do
    expect(described_class).to be_valid("65:30")
  end

  it "Doesn't allow strings" do
    expect(described_class).not_to be_valid("none")
  end
end
