class AllowJudgeToBeEliminated < ActiveRecord::Migration
  def change
    add_column :judges, :status, :string, default: "active", null: false, index: true
  end
end
