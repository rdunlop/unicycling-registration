require 'spec_helper'

RSpec.describe AgeGroupTypeDuplicator do
  let(:age_group_type) { FactoryGirl.create(:age_group_type) }
  let!(:age_group_entry) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type) }

  def do_action
    described_class.new(age_group_type).duplicate
  end

  it 'can duplicate an age group' do
    expect{ do_action }.to change(AgeGroupType, :count).by 1
  end

  it 'can duplicate an age group with entries' do
    expect{ do_action }.to change(AgeGroupEntry, :count).by 1
  end
end
