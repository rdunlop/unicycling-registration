module LanguageHelper
  def languages
    I18n.available_locales
  end

  def long_language_name(language)
    t("language_name", locale: language)
  end
end
