require 'spec_helper'

RSpec.describe AgeGroupEntryCombiner do
  let(:age_group_type) { FactoryGirl.create(:age_group_type) }
  let!(:age_group_entry) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type, start_age: 0, end_age: 10) }
  let!(:age_group_entry_2) { FactoryGirl.create(:age_group_entry, age_group_type: age_group_type, start_age: 11, end_age: 20) }

  def do_action
    described_class.new(age_group_entry.id, age_group_entry_2.id).combine
  end

  it 'can rename the age group entry' do
    expect{ do_action }.to change{ age_group_entry.reload.short_description }
  end

  it 'can remove the age group entry' do
    expect{ do_action }.to change(AgeGroupEntry, :count).by(-1)
  end
end
