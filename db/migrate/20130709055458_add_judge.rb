class AddJudge < ActiveRecord::Migration
  def change
      create_table :judges do |t|
        t.integer  :event_category_id
        t.integer  :judge_type_id
        t.integer  :user_id
        t.timestamps
      end
  end
end
