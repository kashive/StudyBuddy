class AddCourseIdToStudySession < ActiveRecord::Migration
  def change
    add_column :study_sessions, :course_id, :integer
  end
end
