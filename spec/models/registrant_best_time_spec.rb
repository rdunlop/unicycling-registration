# == Schema Information
#
# Table name: registrant_best_times
#
#  id              :integer          not null, primary key
#  event_id        :integer          not null
#  registrant_id   :integer          not null
#  source_location :string           not null
#  value           :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_registrant_best_times_on_event_id_and_registrant_id  (event_id,registrant_id) UNIQUE
#  index_registrant_best_times_on_registrant_id               (registrant_id)
#

require 'spec_helper'

describe RegistrantBestTime do
  before do
    @rb = FactoryGirl.create(:registrant_best_time)
  end

  it "is valid from FactoryGirl" do
    expect(@rb).to be_valid
  end

  it "can store a large value" do
    @rb.value = 3 * 60 * 60 * 1000 # hours, in miliseconds
    @rb.save
    expect(@rb).to be_valid
  end
end
