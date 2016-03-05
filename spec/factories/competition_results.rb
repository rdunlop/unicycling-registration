# == Schema Information
#
# Table name: competition_results
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  results_file   :string(255)
#  system_managed :boolean          default(FALSE), not null
#  published      :boolean          default(FALSE), not null
#  published_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string(255)
#

FactoryGirl.define do
  factory :competition_result do
    competition # FactoryGirl

    results_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', "sample.pdf"), "application/pdf") }
    system_managed false
    published true
    published_date Date.current
    sequence(:name) { |n| "My new result#{n}" }
  end
end
