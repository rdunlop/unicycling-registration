class ImportsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_action

  def index; end

  def import_registrants
    importer = Importers::RegistrantDataImporter.new(current_user)
    parser = Importers::Parsers::RegistrantImport.new

    if importer.process(params[:file], parser)
      flash[:notice] = "Import Successful"
    else
      flash[:alert] = "#{importer.num_rows_processed} rows imported. Some Import errors: #{importer.errors[0..10]}"
    end
    redirect_to imports_path
  end

  def new; end

  def create
    class_name = params[:class_name].constantize
    file = params[:file]
    ext = CsvExtractor.new(file)
    array_of_user_hashes = ext.extract_csv
    importer = ImportsTable.new(class_name)
    success_count = 0
    error_count = 0
    array_of_user_hashes.each do |user_hash|
      if importer.import(user_hash)
        success_count += 1
      else
        error_count += 1
      end
    end
    # if we imported records which set the 'id' column, we must reset the sequence or we will have collisions
    # on future object creations
    # ActiveRecord::Base.connection.execute("SELECT setval(pg_get_serial_sequence('registrants','id'), max(id)) FROM registrants")
    flash[:notice] = "#{success_count} #{class_name} imported"
    flash[:alert] = "#{error_count} #{class_name} not imported"
    redirect_to new_import_path
  end

  private

  def authorize_action
    authorize :import
  end
end
