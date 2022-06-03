# == Schema Information
#
# Table name: competition_results
#
#  id             :integer          not null, primary key
#  competition_id :integer
#  results_file   :string
#  system_managed :boolean          default(FALSE), not null
#  published      :boolean          default(FALSE), not null
#  published_date :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  name           :string
#

FactoryBot.define do
  factory :competition_result do
    competition # FactoryBot

    results_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', "sample.pdf"), "application/pdf") }
    system_managed { false }
    published { true }
    published_date { DateTime.current }
    sequence(:name) { |n| "My new result#{n}" }
  end
end
