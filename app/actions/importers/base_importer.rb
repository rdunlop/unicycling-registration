class BaseImporter
  attr_accessor :competition, :user, :num_rows_processed, :errors

  def initialize(competition, user)
    @competition = competition
    @user = user
  end

  def valid_file?(file)
    if file.blank?
      @errors = "File not found"
      return false
    end

    true
  end
end
