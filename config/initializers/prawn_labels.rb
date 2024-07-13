# THIS ASSUMES A 72 PPI resolution
# Thus, a full inch is 72 Points
#
# 0.1 INCH = 7.2 Pts
# 1 INCH = 25.4 mm
# 1 mm = 2.835 Pts
Prawn::Labels.types = {
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
    "top_margin" => 38.23,  # 0.47 inch (DPI => ~.53 inch)
    "bottom_margin" => 38.23,
    "left_margin" => 32.23, # 0.44 inch (DPI => ~.447 inch)
    "right_margin" => 26.23,
    "columns" => 4,
    "rows" => 6,
    "column_gutter" => 32.152, # ~ 3/8 inch (0.375 inch) (DPI => ~.446 inch)
    "row_gutter" => 6.152 # 1/16 inch
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
    "row_gutter" => 2.5 # added padding
  },
  "Avery5434" => {
    "paper_size" => [288, 432], # 4x6 inch
    "columns" => 2,
    "rows" => 5,
    "top_margin" => 36,      # 0.5 inch
    "bottom_margin" => 36,   # 0.5 inch
    "column_gutter" => 18, # 0.05 inch + 0.2 inch padding
    "left_margin" => 41.4, # 0.475 inch + 0.1 inch padding (0.1 inch => 7.2 DPI)
    "right_margin" => 41.4, # 0.475 inch + 0.1 inch padding
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
    "left_margin" => 74.3, # 0.89 inch + 0.1 inch padding => 64.08 DPI + 10.22 DPI (~1.4inch)
    "right_margin" => 74.3 # 0.89 inch + 0.1 inch padding
  },
  "L7161" => {
    "paper_size" => "A4",
    "columns" => 3,
    "rows" => 6,
    "top_margin" => 25.6, # 0.31 inch + 0.06 inch padding => 22.32 DPI + 4.32 DPI
    "bottom_margin" => 25.6,
    "column_gutter" => 16.2, # 1/8 inch + 0.1 inch padding (9 DPI + 7.2 DPI)
    "row_gutter" => 4.5, # 1/16 inch
    "left_margin" => 27.36, # 0.28 inch + 0.1 inch padding (20.16 DPI + 7.2 DPI)
    "right_margin" => 27.36
  },
  "L7651" => {
    "paper_size" => "A4",
    "columns" => 5,
    "rows" => 13,
    "top_margin" => 28.35, # 10 mm + 0 padding => 28.346472 DPI
    "bottom_margin" => 28.35,
    "column_gutter" => 7.09, # 2.5 mm + 0 padding => 7.0866143999999 DPI
    "row_gutter" => 1, # 1/7 inch
    "left_margin" => 14.18, # 5 mm + 0 padding => 14.1732 DPI
    "right_margin" => 14.18
  },
  "Avery8167" => {
    "paper_size" => "LETTER",
    "columns" => 4,
    "rows" => 20,
    "top_margin" => 36, # 0.5" + 0 padding => 36 Pts
    "bottom_margin" => 36,
    "column_gutter" => 23.47, # 0.326" => 22.32 Pts
    "row_gutter" => 1, # 1/7 inch
    "left_margin" => 21.6, # 8 mm + 0 padding => 14.1732 DPI
    "right_margin" => 21.6
  }
}
