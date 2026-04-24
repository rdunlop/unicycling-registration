FactoryBot.define do
  factory :mail_opt_out do
    sequence(:email) { |n| "EmailMyString+#{n}@example.com" }
    opted_out { true }
  end
end

# == Schema Information
#
# Table name: mail_opt_outs
#
#  id           :bigint           not null, primary key
#  opt_out_code :string           not null
#  opted_out    :boolean          default(FALSE), not null
#  email        :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_mail_opt_outs_on_email         (email) UNIQUE
#  index_mail_opt_outs_on_opt_out_code  (opt_out_code) UNIQUE
#
