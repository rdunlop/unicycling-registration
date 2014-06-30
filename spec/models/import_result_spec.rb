# == Schema Information
#
# Table name: import_results
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  raw_data       :string(255)
#  bib_number     :integer
#  minutes        :integer
#  seconds        :integer
#  thousands      :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  competition_id :integer
#  rank           :integer
#  details        :string(255)
#  is_start_time  :boolean          default(FALSE)
#  attempt_number :integer
#  status         :string(255)
#  comments       :text
#

require 'spec_helper'

describe ImportResult do
  before(:each) do
    @ir = FactoryGirl.build_stubbed(:import_result)
  end
  it "has a valid factory" do
    @ir.valid?.should == true
  end

  it "requires a user" do
    @ir.user_id = nil
    @ir.valid?.should == false
  end

  it "requires a competition" do
    @ir.competition_id = nil
    @ir.valid?.should == false
  end

  it "automatically sets the details if none are specified" do
    @ir.rank = 5
    @ir.details = ""
    expect(@ir).to be_valid
    expect(@ir.details).to eq("5pts")
  end

end
