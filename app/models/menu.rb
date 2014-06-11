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

    def permitted_entries
      @permitted_entries ||= entries.select{ |entry| entry.permitted }
    end

    def has_permitted_entry
      return true if self.is_link
      permitted_entries.count > 0
    end
  end

  class MenuEntry
    attr_accessor :title
    attr_accessor :url
    attr_accessor :permitted

    def initialize(attributes = {})
      self.permitted = true
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end
end
