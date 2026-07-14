class SeedSystemLabelTypes < ActiveRecord::Migration[8.1]
  DESCRIPTIONS = {
    "Avery5160padded" => "Square Labels",
    "Avery8293" => "Round Labels",
    "Avery5434" => "Square Labels",
    "Spanish4716" => "Square Labels 4716 (A4 Paper)",
    "LS3639" => "Round Korean Labels",
    "Avery5293" => "Round Labels",
    "Avery5293padded" => "Round Labels Avery (slightly padded)",
    "Avery5293smallsquare" => "Round Labels Avery (heavily padded)",
    "L7651" => "Square Labels Avery",
    "L7161" => "Round Labels (3 columns, 6 rows, A4 Paper)",
    "Avery8167" => "Square Labels (4 columns, 20 rows)"
  }.freeze

  # THIS ASSUMES A 72 PPI resolution
  TYPES = {
    "Spanish4716" => {
      "paper_size" => "A4",
      "top_margin" => 28.09,
      "bottom_margin" => 28.09,
      "left_margin" => 28.09,
      "right_margin" => 28.09,
      "columns" => 5,
      "rows" => 13,
      "column_gutter" => 20,
      "row_gutter" => 0
    },
    "Avery5293" => {
      "paper_size" => "LETTER",
      "top_margin" => 38.23,
      "bottom_margin" => 38.23,
      "left_margin" => 32.23,
      "right_margin" => 32.23,
      "columns" => 4,
      "rows" => 6,
      "column_gutter" => 32.152,
      "row_gutter" => 6.152
    },
    "Avery5293padded" => {
      "paper_size" => "LETTER",
      "top_margin" => 45.23,
      "bottom_margin" => 42.23,
      "left_margin" => 35.23,
      "right_margin" => 38.23,
      "columns" => 4,
      "rows" => 6,
      "column_gutter" => 48.152,
      "row_gutter" => 12.152
    },
    "Avery5293smallsquare" => {
      "paper_size" => "LETTER",
      "top_margin" => 55.23,
      "bottom_margin" => 55.23,
      "left_margin" => 50.23,
      "right_margin" => 55.23,
      "columns" => 4,
      "rows" => 6,
      "column_gutter" => 65.152,
      "row_gutter" => 32.152
    },
    "Avery8293" => {
      "paper_size" => "LETTER",
      "top_margin" => 65.23,
      "bottom_margin" => 54.23,
      "left_margin" => 45.23,
      "right_margin" => 45.23,
      "columns" => 4,
      "rows" => 5,
      "column_gutter" => 55,
      "row_gutter" => 50
    },
    "Avery5160padded" => {
      "paper_size" => "LETTER",
      "top_margin" => 36,
      "bottom_margin" => 36,
      "left_margin" => 15.822,
      "right_margin" => 15.822,
      "columns" => 3,
      "rows" => 10,
      "column_gutter" => 15,
      "row_gutter" => 2.5
    },
    "Avery5434" => {
      "paper_size" => "CUSTOM",
      "paper_size_custom" => "288,432",
      "columns" => 2,
      "rows" => 5,
      "top_margin" => 36,
      "bottom_margin" => 36,
      "column_gutter" => 18,
      "left_margin" => 41.4,
      "right_margin" => 41.4,
      "row_gutter" => 0.0
    },
    "LS3639" => {
      "paper_size" => "A4",
      "columns" => 4,
      "rows" => 5,
      "top_margin" => 90.6,
      "bottom_margin" => 84.6,
      "column_gutter" => 32.5,
      "row_gutter" => 42.38,
      "left_margin" => 74.3,
      "right_margin" => 74.3
    },
    "L7161" => {
      "paper_size" => "A4",
      "columns" => 3,
      "rows" => 6,
      "top_margin" => 25.6,
      "bottom_margin" => 25.6,
      "column_gutter" => 16.2,
      "row_gutter" => 4.5,
      "left_margin" => 27.36,
      "right_margin" => 27.36
    },
    "L7651" => {
      "paper_size" => "A4",
      "columns" => 5,
      "rows" => 13,
      "top_margin" => 28.35,
      "bottom_margin" => 28.35,
      "column_gutter" => 7.09,
      "row_gutter" => 1,
      "left_margin" => 14.18,
      "right_margin" => 14.18
    },
    "Avery8167" => {
      "paper_size" => "LETTER",
      "columns" => 4,
      "rows" => 20,
      "top_margin" => 36,
      "bottom_margin" => 36,
      "column_gutter" => 23.47,
      "row_gutter" => 1,
      "left_margin" => 21.6,
      "right_margin" => 21.6
    }
  }.freeze

  def up
    Apartment::Tenant.switch("public") do
      TYPES.each do |name, attrs|
        next if SystemLabelType.exists?(name: name)

        SystemLabelType.create!(
          name: name,
          description: DESCRIPTIONS[name],
          paper_size: attrs["paper_size"],
          paper_size_custom: attrs["paper_size_custom"],
          columns: attrs["columns"],
          rows: attrs["rows"],
          top_margin: attrs["top_margin"],
          bottom_margin: attrs["bottom_margin"],
          left_margin: attrs["left_margin"],
          right_margin: attrs["right_margin"],
          column_gutter: attrs["column_gutter"],
          row_gutter: attrs["row_gutter"]
        )
      end
    end
  end

  def down
    Apartment::Tenant.switch("public") do
      SystemLabelType.where(name: TYPES.keys).destroy_all
    end
  end
end
