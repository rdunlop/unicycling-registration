module LabelTypeAttributes
  extend ActiveSupport::Concern

  PAPER_SIZES = ['A4', 'LETTER', 'CUSTOM'].freeze

  included do
    validates :name, presence: true, uniqueness: true
    validates :paper_size, inclusion: { in: PAPER_SIZES }
    validates :paper_size_custom, presence: true, if: proc { |el| el.paper_size == 'CUSTOM' }

    validates :columns, :rows, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 20 }

    validates :left_margin, :right_margin, :bottom_margin, :top_margin, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }

    validates :column_gutter, presence: true
  end

  def paper_size_value
    if paper_size == "CUSTOM"
      paper_size_custom.split(",").map(&:to_i)
    else
      paper_size
    end
  end

  def to_prawn_type_hash
    {
      "paper_size" => paper_size_value,
      "top_margin" => top_margin,
      "bottom_margin" => bottom_margin,
      "left_margin" => left_margin,
      "right_margin" => right_margin,
      "columns" => columns,
      "rows" => rows,
      "column_gutter" => column_gutter,
      "row_gutter" => row_gutter
    }
  end

  # [header, value] pairs describing this label type, used to fill each cell
  # of a test print with useful calibration info instead of a bare number.
  def test_print_info_fields
    [
      ["Label Name", name],
      ["Description", description],
      ["Paper Size", paper_size == "CUSTOM" ? paper_size_custom : paper_size],
      ["Columns", columns],
      ["Rows", rows],
      ["Top Margin", "#{top_margin}pts"],
      ["Bottom Margin", "#{bottom_margin}pts"],
      ["Left Margin", "#{left_margin}pts"],
      ["Right Margin", "#{right_margin}pts"],
      ["Column Gutter", "#{column_gutter}pts"],
      ["Row Gutter", "#{row_gutter}pts"]
    ]
  end
end
