class AddPublicToStudySessions < ActiveRecord::Migration
  def change
  	add_column :study_sessions, :is_private, :boolean
  end
end
