# == Schema Information
#
# Table name: award_labels
#
#  id            :integer          not null, primary key
#  bib_number    :integer
#  line_2        :string(255)
#  line_3        :string(255)
#  line_5        :string(255)
#  place         :integer
#  user_id       :integer
#  registrant_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  line_1        :string(255)
#  line_4        :string(255)
#
# Indexes
#
#  index_award_labels_on_user_id  (user_id)
#

require 'spec_helper'

describe AwardLabel do
  before(:each) do
    @al = FactoryGirl.build_stubbed(:award_label)
  end

  it "has a valid factory" do
    expect(@al.valid?).to eq(true)
  end

  it "must have a registrant" do
    @al.registrant_id = nil
    expect(@al.valid?).to eq(false)
  end

  it "must have a user" do
    @al.user_id = nil
    expect(@al.valid?).to eq(false)
  end

  it "must have a place" do
    @al.place = nil
    expect(@al.valid?).to eq(false)
  end

  it "must have a positive place" do
    @al.place = 0
    expect(@al.valid?).to eq(false)
  end

  it "translates from places to line6" do
    @al.place = 1
    expect(@al.line_6).to eq("1st Place")
    @al.place = 2
    expect(@al.line_6).to eq("2nd Place")
    @al.place = 3
    expect(@al.line_6).to eq("3rd Place")
    @al.place = 4
    expect(@al.line_6).to eq("4th Place")
    @al.place = 5
    expect(@al.line_6).to eq("5th Place")
    @al.place = 6
    expect(@al.line_6).to eq("6th Place")
  end
end
