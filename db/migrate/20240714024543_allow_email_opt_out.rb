class AllowEmailOptOut < ActiveRecord::Migration[7.0]
  def change
    create_table :mail_opt_outs do |t|
      t.string :opt_out_code, null: false
      t.boolean :opted_out, null: false, default: false
      t.string :email, null: false
      t.timestamps
    end
    add_index :mail_opt_outs, :opt_out_code, unique: true
    add_index :mail_opt_outs, :email, unique: true
  end
end
