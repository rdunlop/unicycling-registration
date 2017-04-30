require 'spec_helper'

class Entry
  attr_accessor :minutes, :seconds, :thousands
  include HoursFacade
end

describe "Entry" do
  let(:subject) { Entry.new }

  it "can calculate thousands from hundreds" do
    subject.facade_hundreds = 123
    expect(subject.thousands).to eq(1230)
  end

  it "can change minutes without affecting hours" do
    subject.facade_minutes = 5
    subject.facade_hours = 1
    subject.facade_minutes = 10
    expect(subject.facade_hours).to eq(1)
    expect(subject.facade_minutes).to eq(10)
    expect(subject.minutes).to eq(70)
  end
end
