class AddCommentsAttemptsAndStatusToTimeResults < ActiveRecord::Migration
  class TimeResult < ActiveRecord::Base
  end

  def up
    add_column :time_results, :attempt_number, :integer
    add_column :time_results, :status, :string
    add_column :time_results, :comments, :text

    TimeResult.reset_column_information

    TimeResult.where(disqualified: true).each do |time_result|
      time_result.update_attribute(:status, "DQ")
    end

    remove_column :time_results, :disqualified
  end

  def down
    add_column :time_results, :disqualified, :boolean

    TimeResult.reset_column_information

    TimeResult.where(status: "DQ").each do |time_result|
      time_result.update_attribute(:disqualified, true)
    end

    remove_column :time_results, :attempt_number
    remove_column :time_results, :status
    remove_column :time_results, :comments
  end
end
