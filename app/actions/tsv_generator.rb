# Creates a Tab-separated export file
class TsvGenerator
  attr_accessor :exporter

  def initialize(exporter)
    @exporter = exporter
  end

  def generate
    CSV.generate(col_sep: "\t") do |csv|
      csv << exporter.headers if exporter.headers.present?
      exporter.rows.each do |row|
        csv << row
      end
    end
  end
end
