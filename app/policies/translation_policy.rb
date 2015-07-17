class TranslationPolicy < ApplicationPolicy
  def index?
    convention_admin? || translator? || super_admin?
  end

  def manage_all_site_translations?
    translator? || super_admin?
  end
end
