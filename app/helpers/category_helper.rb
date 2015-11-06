module CategoryHelper
  def additional_information_url(category, locale = I18n.locale)
    category.info_url.presence || (category.info_page.present? && page_url(category.info_page.slug, locale: locale, framed: true))
  end
end
