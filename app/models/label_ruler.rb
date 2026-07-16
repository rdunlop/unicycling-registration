# Draws a measurement ruler (tick marks + labels) along the top and left
# edges of the current page of a Prawn::Document, for calibrating label
# margins/tolerances. Scaled in Points (Pts) since that's the unit
# SystemLabelType/CustomLabelType margins and gutters are specified in.
class LabelRuler
  PAPER_SIZES = ['A4', 'LETTER'].freeze
  MINOR_TICK_EVERY_PT = 10
  MAJOR_TICK_EVERY_PT = 50

  def self.draw!(document)
    new(document).draw
  end

  def initialize(document)
    @document = document
  end

  def draw
    @document.go_to_page(1)
    @document.stroke_color "FF0000"
    draw_horizontal_ruler
    draw_vertical_ruler
    @document.stroke_color "000000"
  end

  private

  def draw_horizontal_ruler
    width = @document.bounds.width
    height = @document.bounds.height
    pt = 0
    while pt <= width
      major = (pt % MAJOR_TICK_EVERY_PT).zero?
      tick_length = major ? 8 : 4
      @document.stroke_line [pt, height], [pt, height - tick_length]
      @document.draw_text "#{pt}pt", at: [pt + 1, height - tick_length - 7], size: 5 if major
      pt += MINOR_TICK_EVERY_PT
    end
  end

  def draw_vertical_ruler
    height = @document.bounds.height
    pt = 0
    y = height
    while y >= 0
      major = (pt % MAJOR_TICK_EVERY_PT).zero?
      tick_length = major ? 8 : 4
      @document.stroke_line [0, y], [tick_length, y]
      @document.draw_text "#{pt}pt", at: [tick_length + 2, y - 2], size: 5 if major
      y -= MINOR_TICK_EVERY_PT
      pt += MINOR_TICK_EVERY_PT
    end
  end
end
