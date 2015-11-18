module CategoryHelper
  def additional_information_url(category, locale = I18n.locale, prefix = "info")
    category.send("#{prefix}_url").presence || (category.send("#{prefix}_page").present? && page_url(category.send("#{prefix}_page").slug, locale: locale, framed: true))
  end
end
