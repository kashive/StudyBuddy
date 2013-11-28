class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :host_id
      t.string :user_id
      t.string :course_id
      t.string :study_session_id
      t.string :status

      t.timestamps
    end
  end
end
