class AddReminderColumnsToStudySessions < ActiveRecord::Migration
  def change
  	add_column :study_sessions, :twoHourReminder, :boolean
  	add_column :study_sessions, :twentyFourHourReminder, :boolean
  end
end
