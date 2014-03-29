# == Schema Information
#
# Table name: registrant_event_sign_ups
#
#  id                :integer          not null, primary key
#  registrant_id     :integer
#  signed_up         :boolean
#  event_category_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  event_id          :integer
#

require 'spec_helper'

describe RegistrantEventSignUp do
  before(:each) do
    @re = FactoryGirl.create(:registrant_event_sign_up)
  end
  it "is valid from FactoryGirl" do
    @re.valid?.should == true
  end
  it "requires an event_category" do
    @re.event_category = nil
    @re.valid?.should == false
  end

  it "requires a registrant" do
    @re.registrant = nil
    @re.valid?.should == false
  end
end
