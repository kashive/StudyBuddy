class CreateMarketings < ActiveRecord::Migration
  def change
    create_table :marketings do |t|
      t.string :inviting_user_id
      t.boolean :status
      t.integer :times_contacted
      t.string :email
      t.string :course_id
      t.string :study_session_id

      t.timestamps
    end
  end
end
