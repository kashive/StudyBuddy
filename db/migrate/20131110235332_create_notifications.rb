class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :creator_id
      t.string :invitee_id
      t.string :course_id
      t.string :session_id
      t.string :type
      t.boolean :seen

      t.timestamps
    end
  end
end
