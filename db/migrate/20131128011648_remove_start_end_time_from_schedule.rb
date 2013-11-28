class RemoveStartEndTimeFromSchedule < ActiveRecord::Migration
 def change
  	remove_column :schedules, :start_time
  	remove_column :schedules, :end_time
  	add_column :schedules, :start_time, :string
  	add_column :schedules, :end_time, :string
  end
end
