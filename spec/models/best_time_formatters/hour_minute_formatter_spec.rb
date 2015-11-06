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

describe HourMinuteFormatter do
  it "converts one minute to hundreds" do
    expect(described_class.from_string("0:01")).to eq(6000)
  end

  it "converts 6000 to 1 minute" do
    expect(described_class.to_string(6000)).to eq("0:01")
  end

  it "marks empty as invalid" do
    expect(described_class.valid?("")).to be_falsey
  end

  it "marks real string as valid" do
    expect(described_class.valid?("1:00")).to be_truthy
  end

  it "doesnt't allow minutes over 59" do
    expect(described_class.valid?("0:60")).to be_falsey
  end

  it "doesn't allow negative hours" do
    expect(described_class.valid?("-1:0")).to be_falsey
  end
end
