class Importers::BaseImporter
  attr_accessor :user, :num_rows_processed

  def initialize(user)
    @user = user
    @errors = []
  end

  def valid_file?(file)
    if file.blank?
      @errors << "File not found"
      return false
    end

    true
  end

  def errors
    @errors.join(", ")
  end
end
