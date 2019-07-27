FactoryBot.define do
  factory :convention_series do
    sequence(:name) { |n| "The Series #{n}" }
  end
end

# == Schema Information
#
# Table name: public.convention_series
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_convention_series_on_name  (name) UNIQUE
#
