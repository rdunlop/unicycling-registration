class ReplaceComplexAwardModelWithSimpleOne < ActiveRecord::Migration
  def up
    change_table :award_labels do |t|
      t.remove :first_name
      t.remove :last_name
      t.remove :partner_first_name
      t.remove :partner_last_name
      t.remove :age_group
      t.remove :gender

      t.string :competitor_name
      t.string :category
    end
  end

  def down
    change_table :award_labels do |t|
      t.string :first_name
      t.string :last_name
      t.string :partner_first_name
      t.string :partner_last_name
      t.string :age_group
      t.string :gender

      t.remove :competitor_name
      t.remove :category
    end
  end
end
