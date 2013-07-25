class Printing::RaceRecordingController < ApplicationController
  before_filter :authenticate_user!
  skip_authorization_check

  def list
  end

  def instructions
    respond_to do |format|
      format.html # multi_lap.html.erb
      format.pdf { render_common_pdf("instructions") }
    end
  end

  def multi_lap
    respond_to do |format|
      format.html # multi_lap.html.erb
      format.pdf { render_common_pdf("multi_lap") }
    end
  end
end

