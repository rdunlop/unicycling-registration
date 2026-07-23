# When specified, these custom labels types
# are available for use when creating award labels
# == Schema Information
#
# Table name: custom_label_types
#
#  id                :bigint           not null, primary key
#  name              :string           not null
#  paper_size        :string           not null
#  paper_size_custom :string
#  columns           :integer          not null
#  rows              :integer          not null
#  top_margin        :float            not null
#  bottom_margin     :float            not null
#  left_margin       :float            not null
#  right_margin      :float            not null
#  column_gutter     :float            not null
#  row_gutter        :float            not null
#  created_by_id     :integer          not null
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class CustomLabelType < ApplicationRecord
  include LabelTypeAttributes

  validates :created_by_id, presence: true
  validate :name_not_a_system_label_type

  belongs_to :created_by, class_name: "User", optional: true

  private

  def name_not_a_system_label_type
    return if name.blank?

    if SystemLabelType.exists?(name: name)
      errors.add(:name, "is already used by a system label type")
    end
  end
end
