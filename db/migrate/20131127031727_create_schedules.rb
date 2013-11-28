class CreateSchedules < ActiveRecord::Migration
  def change
    create_table :schedules do |t|
      t.string :user_id
      t.string :day
      t.string :course_id
      t.time :start_time
      t.time :end_time

      t.timestamps
    end
  end
end
