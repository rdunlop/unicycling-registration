module LanguageHelper
  def languages
    I18n.available_locales
  end

  def long_language_name(language)
    t("language_name", locale: language)
  end

  def cache_i18n(keys, options = {})
    cache [:i18n, I18n.locale, *keys], options do
      yield
    end
  end

  # Clear any keys which were written by the `cache_i18n` function above
  def clear_cache_i18n
    Rails.cache.delete_matched 'views/i18n/*'
  end
end
