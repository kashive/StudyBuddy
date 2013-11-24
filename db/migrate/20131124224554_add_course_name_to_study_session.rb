class AddCourseNameToStudySession < ActiveRecord::Migration
  def change
    add_column :study_sessions, :course_name, :string
  end
end
