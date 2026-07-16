# THIS ASSUMES A 72 PPI resolution
# Thus, a full inch is 72 Points
#
# 0.1 INCH = 7.2 Pts
# 1 INCH = 25.4 mm
# 1 mm = 2.835 Pts
#
# Actual label type data now lives in SystemLabelType/CustomLabelType (DB-backed);
# see LabelTypeRegistry.load_into_prawn!, which populates this hash at request time.
Prawn::Labels.types = {}

# Monkey-batch Prawn-labels so that I can adjust the expected line-length requirement.
module Prawn
  class Labels
    def shrink_text(record)
      linecount = (split_lines = record.split("\n")).length

      # 15 is estimated max character length per line.
      split_lines.each { |line| linecount += line.length / 13 } # Total hack to make square labels work.

      # -10 accounts for the overflow margins
      rowheight = @document.grid.row_height - 10

      if linecount <= rowheight / 12.floor
        @document.font_size = 12
      else
        @document.font_size = rowheight / (linecount + 1)
      end
    end
  end
end
