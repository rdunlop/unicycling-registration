class AllowJudgeToBeEliminated < ActiveRecord::Migration[4.2]
  def change
    add_column :judges, :status, :string, default: "active", null: false, index: true
  end
end
