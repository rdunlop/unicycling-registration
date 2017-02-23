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
  let(:event) { FactoryGirl.create :event, :marathon_best_time_format }
  before do
    @rb = FactoryGirl.create(:registrant_best_time, event: event)
  end

  it "is valid from FactoryGirl" do
    expect(@rb).to be_valid
  end

  describe "#to_s" do
    it "includes formatted value and location" do
      expect(@rb.to_s).to eq("Best Time: 0:10 @ Nationals 2012")
    end

    context "when the event is no longer asking for a best time" do
      before do
        event.update(best_time_format: "none")
      end

      it { expect(@rb.to_s).to be_nil }
    end
  end

  it "can store a large value" do
    @rb.value = 3 * 60 * 60 * 100 # hours, in hundreds-of-seconds
    @rb.save
    expect(@rb).to be_valid
  end

  context "with a h:mm event" do
    before do
      ev = @rb.event
      ev.update_attributes(best_time_format: "h:mm")
    end

    it "stores the converted time in the value" do
      @rb.formatted_value = "0:01"
      @rb.valid? # cause conversion
      expect(@rb.value).to eq(6000)
    end

    it "gives the correct hint" do
      expect(@rb.hint).to eq("h:mm")
    end
  end

  context "doesn't allow incorrectly formatted values" do
    it "gives an error message" do
      @rb.formatted_value = "12"
      expect(@rb).to be_invalid
    end

    it "allows properly formatted values" do
      @rb.formatted_value = "1:20"
      expect(@rb).to be_valid
    end
  end
end
