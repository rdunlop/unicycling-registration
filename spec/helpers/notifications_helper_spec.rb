require 'spec_helper'

describe NotificationsHelper do
  describe '#rich_text_to_plain_text_with_links' do
    it "returns empty string for blank input" do
      expect(helper.rich_text_to_plain_text_with_links(nil)).to eq("")
      expect(helper.rich_text_to_plain_text_with_links("")).to eq("")
    end

    it "converts plain text to plain text" do
      rich_text = ActionText::RichText.new(body: "<p>Hello world</p>")
      result = helper.rich_text_to_plain_text_with_links(rich_text)
      expect(result).to include("Hello world")
    end

    it "preserves links with URLs" do
      rich_text = ActionText::RichText.new(body: '<p>Click <a href="https://example.com">here</a></p>')
      result = helper.rich_text_to_plain_text_with_links(rich_text)
      expect(result).to include("Click")
      expect(result).to include("[https://example.com]")
    end

    it "handles multiple links" do
      html = '<p>Visit <a href="https://example.com">link1</a> or <a href="https://other.com">link2</a></p>'
      rich_text = ActionText::RichText.new(body: html)
      result = helper.rich_text_to_plain_text_with_links(rich_text)
      expect(result).to include("[https://example.com]")
      expect(result).to include("[https://other.com]")
    end

    it "handles image attachments with links" do
      html = '<p>See image: <a href="/rails/active_storage/blobs/abc123/image.jpg"><img src="/rails/active_storage/blobs/abc123/image.jpg"></a></p>'
      rich_text = ActionText::RichText.new(body: html)
      result = helper.rich_text_to_plain_text_with_links(rich_text)
      expect(result).to include("[/rails/active_storage/blobs/abc123/image.jpg]")
    end

    it "handles multiple paragraphs" do
      html = '<p>First paragraph</p><p>Second paragraph</p>'
      rich_text = ActionText::RichText.new(body: html)
      result = helper.rich_text_to_plain_text_with_links(rich_text)
      expect(result).to include("First paragraph")
      expect(result).to include("Second paragraph")
    end

    it "strips extra whitespace" do
      rich_text = ActionText::RichText.new(body: "<p>  Text with spaces  </p>")
      result = helper.rich_text_to_plain_text_with_links(rich_text)
      expect(result).not_to start_with(" ")
      expect(result).not_to end_with(" ")
    end
  end
end
