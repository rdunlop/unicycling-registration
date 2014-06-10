class VolunteersController < ApplicationController
  authorize_resource class: false

  def index
    @volunteers = Registrant.active.where(volunteer: true)
  end
end
