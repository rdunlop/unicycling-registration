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

describe MinuteSecondFormatter do
  it "converts one minute to hundreds" do
    expect(described_class.from_string("1:00.00")).to eq(6000)
  end

  it "converts hundreds" do
    expect(described_class.from_string("0:00.59")).to eq(59)
  end

  it "converts full case" do
    expect(described_class.from_string("1:23.45")).to eq(8345)
  end

  it "allows hour/minute only" do
    expect(described_class.valid?("1:30")).to be_truthy
  end

  it "requires that minutes be specified" do
    expect(described_class.valid?("30")).to be_falsey
  end

  it "requires hours be specified" do
    expect(described_class.valid?("30.12")).to be_falsey
  end

  it "doesn't allow seconds/hundreds only" do
    expect(described_class.valid?("0.10")).to be_falsey
  end

  it "converts 6000 to 1 minute" do
    expect(described_class.to_string(6000)).to eq("1:00.00")
  end

  it "converts tens of seconds to hundreds" do
    expect(described_class.from_string("0:00.1")).to eq(10)
  end

  it "marks empty as invalid" do
    expect(described_class.valid?("")).to be_falsey
  end

  it "marks real string as valid" do
    expect(described_class.valid?("1:00.00")).to be_truthy
  end

  it "doesnt't allow seconds over 59" do
    expect(described_class.valid?("0:60")).to be_falsey
  end

  it "doesn't allow negative minutes" do
    expect(described_class.valid?("-1:0")).to be_falsey
  end

  it "allows minutes greater than 60" do
    expect(described_class.valid?("65:30")).to be_truthy
  end

  it "Doesn't allow strings" do
    expect(described_class.valid?("none")).to be_falsey
  end
end
