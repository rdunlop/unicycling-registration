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

describe BestTimeFormatter::CentimeterFormatter do
  it "converts one cm to integer" do
    expect(described_class.from_string("1")).to eq(1)
  end

  it "converts 1 cm to 1 string" do
    expect(described_class.to_string(1)).to eq("1")
  end

  it "doesn't allow fractions" do
    expect(described_class).not_to be_valid("1.23")
  end

  it "marks empty as invalid" do
    expect(described_class).not_to be_valid("")
  end

  it "marks real number as valid" do
    expect(described_class).to be_valid("100")
  end

  it "doesnt't allow centimeters over 600" do
    expect(described_class).not_to be_valid("601")
  end

  it "doesn't allow negative cm" do
    expect(described_class).not_to be_valid("-1")
  end
end
