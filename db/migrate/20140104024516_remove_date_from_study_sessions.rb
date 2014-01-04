class RemoveDateFromStudySessions < ActiveRecord::Migration
	def change
	  	remove_column :study_sessions, :date
  	end
end
