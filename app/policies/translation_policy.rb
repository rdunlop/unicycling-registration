class TranslationPolicy < ApplicationPolicy
  def index?
    convention_admin? || translator? || super_admin? || manage_all_sites_translations?
  end

  def clear_cache?
    index?
  end

  def manage_site_translations?
    index?
  end

  # NOTE: this SHOULD be used by tolk.rb initializer
  def manage_all_sites_translations?
    all_sites_translator? || super_admin?
  end
end
