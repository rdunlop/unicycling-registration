class Importers::HeatFromFilenameExtractor
  def self.extract_heat(filename)
    match_data = /(\d+).(`lif|csv|txt`)$/.match(filename)

    if match_data.nil?
      return nil
    end

    match_data.captures[0].to_i
  end
end
