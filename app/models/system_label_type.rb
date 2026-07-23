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

  # THIS ASSUMES A 72 PPI resolution (0.1 INCH = 7.2 Pts, 1 mm = 2.835 Pts).
  # These are the built-in label types this application has historically shipped with.
  DEFAULTS = {
    "Spanish4716" => {
      description: "Square Labels 4716 (A4 Paper)",
      paper_size: "A4", top_margin: 28.09, bottom_margin: 28.09, left_margin: 28.09, right_margin: 28.09,
      columns: 5, rows: 13, column_gutter: 20, row_gutter: 0
    },
    "Avery5293" => {
      description: "Round Labels",
      paper_size: "LETTER", top_margin: 38.23, bottom_margin: 38.23, left_margin: 32.23, right_margin: 32.23,
      columns: 4, rows: 6, column_gutter: 32.152, row_gutter: 6.152
    },
    "Avery5293padded" => {
      description: "Round Labels Avery (slightly padded)",
      paper_size: "LETTER", top_margin: 45.23, bottom_margin: 42.23, left_margin: 35.23, right_margin: 38.23,
      columns: 4, rows: 6, column_gutter: 48.152, row_gutter: 12.152
    },
    "Avery5293smallsquare" => {
      description: "Round Labels Avery (heavily padded)",
      paper_size: "LETTER", top_margin: 55.23, bottom_margin: 55.23, left_margin: 50.23, right_margin: 55.23,
      columns: 4, rows: 6, column_gutter: 65.152, row_gutter: 32.152
    },
    "Avery8293" => {
      description: "Round Labels",
      paper_size: "LETTER", top_margin: 65.23, bottom_margin: 54.23, left_margin: 45.23, right_margin: 45.23,
      columns: 4, rows: 5, column_gutter: 55, row_gutter: 50
    },
    "Avery5160padded" => {
      description: "Square Labels",
      paper_size: "LETTER", top_margin: 36, bottom_margin: 36, left_margin: 15.822, right_margin: 15.822,
      columns: 3, rows: 10, column_gutter: 15, row_gutter: 2.5
    },
    "Avery5434" => {
      description: "Square Labels",
      paper_size: "CUSTOM", paper_size_custom: "288,432", top_margin: 36, bottom_margin: 36,
      left_margin: 41.4, right_margin: 41.4, columns: 2, rows: 5, column_gutter: 18, row_gutter: 0.0
    },
    "LS3639" => {
      description: "Round Korean Labels",
      paper_size: "A4", top_margin: 90.6, bottom_margin: 84.6, left_margin: 74.3, right_margin: 74.3,
      columns: 4, rows: 5, column_gutter: 32.5, row_gutter: 42.38
    },
    "L7161" => {
      description: "Round Labels (3 columns, 6 rows, A4 Paper)",
      paper_size: "A4", top_margin: 25.6, bottom_margin: 25.6, left_margin: 27.36, right_margin: 27.36,
      columns: 3, rows: 6, column_gutter: 16.2, row_gutter: 4.5
    },
    "L7651" => {
      description: "Square Labels Avery",
      paper_size: "A4", top_margin: 28.35, bottom_margin: 28.35, left_margin: 14.18, right_margin: 14.18,
      columns: 5, rows: 13, column_gutter: 7.09, row_gutter: 1
    },
    "Avery8167" => {
      description: "Square Labels (4 columns, 20 rows)",
      paper_size: "LETTER", top_margin: 36, bottom_margin: 36, left_margin: 21.6, right_margin: 21.6,
      columns: 4, rows: 20, column_gutter: 23.47, row_gutter: 1
    }
  }.freeze

  # Idempotently ensures the built-in system label types exist.
  # Called by the data migration that introduced this table (for dev/prod,
  # where db:migrate runs), and from the test suite's spec_helper (since CI
  # provisions its test DB via db:schema:load, which never runs data
  # migrations at all).
  def self.seed_defaults!
    DEFAULTS.each do |name, attrs|
      next if exists?(name: name)

      create!(attrs.merge(name: name))
    end
  end
end
