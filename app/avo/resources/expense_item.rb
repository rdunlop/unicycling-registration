class Avo::Resources::ExpenseItem < Avo::BaseResource
  self.model_class = ::ExpenseItem
  self.title = :name
  self.includes = []
  self.search = {
    query: -> { query.with_translations.where("expense_item_translations.name ILIKE ?", "%#{params[:q]}%") }
  }

  def fields
    field :id, as: :id
    field :name, as: :text
    field :cost_cents, as: :number
    field :has_details, as: :boolean
    field :maximum_available, as: :number
    field :created_at, as: :date_time
  end
end
