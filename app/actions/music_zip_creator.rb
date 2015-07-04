require 'zip'

class MusicZipCreator
  attr_accessor :competition

  def initialize(competition)
    @competition = competition
  end

  # Usage:
  #   MusicZipCreator.new(competition).zip_file(filename) do |zip_file|
  #     send_data(zip_file, :type => 'application/zip', :filename => filename)
  #   end
  def zip_file(filename, &block)
    temp_file = Tempfile.new(filename)
    zip_contents = []

    begin
      #This is the tricky part
      #Initialize the temp file as a zip file
      Zip::OutputStream.open(temp_file) { |zos| }

      #Add files to the zip file as usual
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zip|
        competition.competitors.each do |competitor|
          if competitor.has_music?
            file = LocalResource.new(URI.parse(competitor.music_file.song_file_name_url)).file
            zip_contents << file
            filename = create_filename(competitor.position, competitor.slug, competitor.music_file.human_name)
            zip.add(filename, file)
          end
        end
      end

      #Read the binary data from the file
      zip_data = File.read(temp_file.path)

      #Send the data to the browser as an attachment
      #We do not send the file directly because it will
      #get deleted before rails actually starts sending it
      yield zip_data
    ensure
      zip_contents.each do |file|
        file.close
        file.unlink
      end
      #Close and delete the temp file
      temp_file.close
      temp_file.unlink
    end
  end

  # Create a formatted string,
  # with the position as a 2-digit prefix
  # followed by the competitor name,
  # and the song file name
  # with a suffix of .mp3
  #
  # AND not exceeding 63 characters total
  def create_filename(position, competitor_name, song_file_name)
    name = position.to_s.rjust(2, "0")
    name += "_"
    name += competitor_name
    name += "_"
    name += song_file_name
    name.first(59) + ".mp3"
  end

end
