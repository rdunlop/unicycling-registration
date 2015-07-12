class Printing::RaceRecordingController < ApplicationController
  before_action :authenticate_user!
  skip_authorization

  def instructions
    respond_to do |format|
      format.html
      format.pdf { render_common_pdf("instructions") }
    end
  end

  def blank
    respond_to do |format|
      format.html # blank.html.erb
      format.pdf { render_common_pdf("blank") }
    end
  end
end
