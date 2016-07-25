require 'zip'

class CompetitionHeatTsvZipCreator
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  # Usage:
  #   CompetitionheatTsvZipCreator.new(competition).zip_file(filename) do |zip_file|
  #     send_data(zip_file, :type => 'application/zip', :filename => filename)
  #   end
  def zip_file(filename, &_block)
    temp_file = Tempfile.new(filename)
    zip_contents = []

    begin
      # This is the tricky part
      # Initialize the temp file as a zip file
      Zip::OutputStream.open(temp_file) { |_zos| }

      # Add files to the zip file as usual
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        competition.heat_numbers.each do |heat_number|
          heat_file = Tempfile.new("temp_#{heat_number}", Rails.root.join('tmp')).tap do |f|
            f.write(heat_data_csv(heat_number))
            f.close
          end
          zip_contents << heat_file
          zip.add(create_filename(heat_number), heat_file)
        end
      end

      # Read the binary data from the file
      zip_data = File.read(temp_file.path)

      # Send the data to the browser as an attachment
      # We do not send the file directly because it will
      # get deleted before rails actually starts sending it
      yield zip_data
    ensure
      zip_contents.each do |file|
        file.close
        file.unlink
      end
      # Close and delete the temp file
      temp_file.close
      temp_file.unlink
    end
  end

  def heat_data_csv(heat)
    HeatTsvGenerator.new(competition, heat).generate
  end

  # Create a formatted string,
  # with competition name, and heat_number
  #
  # AND not exceeding 63 characters total
  def create_filename(heat_number)
    name = competition.to_s
    name += "_"
    name += "heat_"
    name += heat_number.to_s.rjust(3, "0")
    name.first(59) + ".txt"
  end
end
