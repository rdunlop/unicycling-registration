class Avo::Resources::EventChoice < Avo::BaseResource
  self.model_class = ::EventChoice
  self.title = :label
  self.includes = []
  self.search = {
    query: -> { query.with_translations.where("event_choice_translations.label ILIKE ?", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :label, as: :text
    field :cell_type, as: :text
    field :optional, as: :boolean
    field :created_at, as: :date_time
  end
end
