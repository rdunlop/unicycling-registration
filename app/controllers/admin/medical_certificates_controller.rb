class Admin::MedicalCertificatesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_permission

  # GET /admin/medical_certificates
  def index
    @registrants = Registrant.competitor.active.includes(:contact_detail, :user)
  end

  # PUT /admin/medical_certificates/:id
  def update
    registrant = Registrant.find_by(id: params[:id])
    registrant.update(medical_certificate_manually_confirmed: !registrant.medical_certificate_manually_confirmed)
    flash[:notice] = "Medical Certificate status toggled"
    redirect_to medical_certificates_path
  end

  private

  def authorize_permission
    authorize :admin_permission
  end
end
