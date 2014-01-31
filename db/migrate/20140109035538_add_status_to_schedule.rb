class AddStatusToSchedule < ActiveRecord::Migration
  def change
  	add_column :schedules, :status, :string
  end
end
