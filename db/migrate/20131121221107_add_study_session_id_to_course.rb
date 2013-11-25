class AddStudySessionIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :study_session_id, :integer
  end
end
