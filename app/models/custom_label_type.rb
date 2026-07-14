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
  validates :name, presence: true
  PAPER_SIZES = ['A4', 'LETTER', 'CUSTOM'].freeze
  validates :paper_size, inclusion: { in: PAPER_SIZES }
  validates :paper_size_custom, presence: true, if: proc { |el| el.paper_size == 'CUSTOM' }

  validates :columns, :rows, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }

  validates :left_margin, :right_margin, :bottom_margin, :top_margin, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }

  validates :created_by_id, presence: true
  validates :column_gutter, presence: true

  belongs_to :created_by, class_name: "User", optional: true

  def paper_size_value
    if paper_size == "CUSTOM"
      paper_size_custom.split(",").map(&:to_i)
    else
      paper_size
    end
  end
end
