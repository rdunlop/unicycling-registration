# == Schema Information
#
# Table name: registrant_choices
#
#  id              :integer          not null, primary key
#  registrant_id   :integer
#  event_choice_id :integer
#  value           :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_registrant_choices_event_choice_id                       (event_choice_id)
#  index_registrant_choices_on_registrant_id_and_event_choice_id  (registrant_id,event_choice_id) UNIQUE
#  index_registrant_choices_registrant_id                         (registrant_id)
#

class RegistrantChoice < ApplicationRecord
  validates :event_choice_id, presence: true, uniqueness: {scope: [:registrant_id]}
  validates :registrant, presence: true

  has_paper_trail meta: { registrant_id: :registrant_id }

  belongs_to :event_choice
  belongs_to :registrant, inverse_of: :registrant_choices, touch: true

  validates :value, format: { with: /\A([0-9]{1,2}:)+[0-9]{2}\z/, message: "must be of the form hh:mm:ss or mm:ss"}, allow_blank: true, if: "event_choice.try(:cell_type) == 'best_time'"

  def has_value?
    case event_choice.cell_type
    when "boolean"
      value != "0"
    when "multiple"
      value != ""
    when "text"
      value.present?
    when "best_time"
      value != ""
    else
      false
    end
  end

  def describe_value
    case event_choice.cell_type
    when "boolean"
      value != "0" ? "yes" : "no"
    else
      value
    end
  end

  def to_s
    describe_value
  end
end
