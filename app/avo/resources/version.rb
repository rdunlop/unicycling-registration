class Avo::Resources::Version < Avo::BaseResource
  self.model_class = PaperTrail::Version
  self.title = :id
  self.includes = []
  self.default_sort_column = :created_at
  self.default_sort_direction = :desc
  self.search = {
    query: lambda {
      q = params[:q].to_s.strip
      if q =~ /\A(\w+)\s+#?(\d+)\z/
        # "User 1" or "User #1" → match type AND id
        query.where(item_type: ::Regexp.last_match(1), item_id: ::Regexp.last_match(2).to_i)
      elsif q =~ /\A\d+\z/
        # plain number → match item_id
        query.where(item_id: q.to_i)
      else
        # text → match item_type or whodunnit
        query.where("item_type ILIKE :q OR whodunnit ILIKE :q", q: "%#{q}%")
      end
    }
  }

  def fields
    field :id, as: :id
    field :item_type, as: :text
    field :item_id, as: :number
    field :event, as: :text
    field :whodunnit, as: :text
    field :object_changes, as: :textarea
    field :created_at, as: :date_time
  end
end
