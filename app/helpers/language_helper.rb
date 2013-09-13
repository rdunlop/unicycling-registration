module LanguageHelper
  @@languages = [
    {:short_name => :en, :long_name => "English"},
    {:short_name => :fr, :long_name => "French"}
  ]
  def languages
    @@languages.collect{|lang| lang[:short_name]}
  end

  def long_language_name(language)
    el = @@languages.select { |lang| lang[:short_name] == language}.first
    el[:long_name] unless el.nil?
  end
end
