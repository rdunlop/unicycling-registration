FactoryBot.define do
  factory :imported_registrant do
    sequence(:first_name) { |n| "FirstMyString #{n}" }
    last_name { "LastMyString" }
    sequence(:bib_number) { |n| n }

    after :stub do |reg|
      reg.bib_number ||= 1234
    end
  end
end
