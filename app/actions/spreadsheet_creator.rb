class SpreadsheetCreator
  def create(headers, data)
    s = Spreadsheet::Workbook.new
    sheet = s.create_worksheet

    headers.each_with_index do |header, index|
      sheet[0, index] = header
    end

    data.each.with_index(1) do |row, index|
      row.each_with_index do |cell, cell_index|
        sheet[index, cell_index] = cell
      end
    end

    s
  end
end
