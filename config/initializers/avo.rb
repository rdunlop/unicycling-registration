Avo.configure do |config|
  config.root_path = "/admin"
  config.current_user_method(&:current_user)
  config.authenticate_with do
    authenticate_user!
    unless current_user&.has_role?(:super_admin)
      redirect_to main_app.root_path, alert: "Not authorized"
    end
  end
  config.app_name = "Workspace Admin"
end
