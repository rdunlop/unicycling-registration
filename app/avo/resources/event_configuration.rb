class Avo::Resources::EventConfiguration < Avo::BaseResource
  self.model_class = ::EventConfiguration
  self.title = :style_name
  self.includes = []
  self.search = {
    query: -> { query.where("style_name ILIKE :q OR contact_email ILIKE :q OR event_url ILIKE :q", q: "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :style_name, as: :text
    field :contact_email, as: :text
    field :event_url, as: :text
    field :start_date, as: :date
    field :created_at, as: :date_time
  end
end
