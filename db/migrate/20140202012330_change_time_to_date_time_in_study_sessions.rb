class ChangeTimeToDateTimeInStudySessions < ActiveRecord::Migration
  def change
  	remove_column :study_sessions, :time
  	add_column :study_sessions, :time, :datetime
  end
end
