class Admin::MedicalCertificatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_permission

  # GET /admin/medical_certificates
  def index
    @registrants = Registrant.active.includes(:contact_detail, :user)
  end

  private

  def authorize_permission
    authorize :admin_permission
  end
end
