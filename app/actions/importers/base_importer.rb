class Importers::BaseImporter
  attr_accessor :user, :num_rows_processed, :errors

  def initialize(user)
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
