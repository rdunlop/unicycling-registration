class Devise::CustomPasswordsController < Devise::PasswordsController
  include LegacyPasswordClearer

  def update
    super do |resource|
      if resource.errors.empty?
        clear_legacy_passwords(resource)
      end
    end
  end
end
