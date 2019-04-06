# Provides a way to output Excel files
module ExcelOutputter
  def output_spreadsheet(headers, data, filename)
    s = SpreadsheetCreator.new.create(headers, data)

    report = StringIO.new
    s.write report

    send_data report.string, filename: "#{filename}.xls"
  end
end
