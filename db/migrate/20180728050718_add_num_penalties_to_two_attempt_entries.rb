class AddNumPenaltiesToTwoAttemptEntries < ActiveRecord::Migration[5.1]
  def change
    add_column :two_attempt_entries, :number_of_penalties_1, :integer
    add_column :two_attempt_entries, :number_of_penalties_2, :integer
  end
end
