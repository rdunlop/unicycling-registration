FactoryBot.define do
  factory :export do
    association :exported_by, factory: :user
    export_type { "results" }
    file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'invalid_sample_wave_assignments.xlsx'), 'text/plain') }
  end
end
