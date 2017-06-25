# Provides a way to output Csv files
module CsvOutputter
  def output_csv(headers, rows, filename)
    csv_string = CSV.generate do |csv|
      csv << headers
      rows.each do |row|
        csv << row
      end
    end
    send_data(csv_string,
              type: 'text/csv; charset=utf-8; header=present',
              filename: filename)
  end
end
