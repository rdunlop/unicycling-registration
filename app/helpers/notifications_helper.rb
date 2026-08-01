module NotificationsHelper
  def rich_text_to_plain_text_with_links(rich_text)
    return "" if rich_text.blank?

    html = rich_text.body.to_html
    doc = Nokogiri::HTML.fragment(html)

    text = ""
    doc.traverse do |node|
      case node
      when Nokogiri::XML::Text
        text += node.text
      when Nokogiri::XML::Element
        text += " [#{node['href']}] " if node.name == 'a' && node['href']
        text += "\n" if %w[p div br].include?(node.name)
      end
    end

    text.strip
  end
end
