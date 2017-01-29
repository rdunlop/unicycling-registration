# Clears all legacy passwords
module LegacyPasswordClearer
  def clear_legacy_passwords(user)
    user.user_conventions.each do |user_convention|
      user_convention.update(legacy_encrypted_password: nil)
    end
  end
end
