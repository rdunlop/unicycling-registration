# These are the label types built into the system, and shared across
# all conventions (apartment excluded_model - single shared table).
# == Schema Information
#
# Table name: public.system_label_types
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
#  description       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_system_label_types_on_name  (name) UNIQUE
#
class SystemLabelType < ApplicationRecord
  include LabelTypeAttributes
end
