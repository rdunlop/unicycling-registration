class Menu

  def headings
    @headings ||= []
  end

  class MenuHeading

    attr_accessor :title
    attr_accessor :is_link
    attr_accessor :url

    def initialize(attributes = {})
      self.is_link = false

      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def entries
      @entries ||= []
    end

    def active
      entries.any? {|entry| entry.active }
    end

    def has_permitted_entry
      return true if self.is_link
      entries.any? {|entry| entry.permitted }
    end
  end

  class MenuEntry
    attr_accessor :title
    attr_accessor :url
    attr_accessor :active
    attr_accessor :permitted

    def initialize(attributes = {})
      self.active = false
      self.permitted = true
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
