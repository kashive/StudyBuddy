class RemoveCourseIdFromEnrollment < ActiveRecord::Migration
 def change
  	remove_column :enrollments, :course_id
  	add_column :enrollments, :course_name, :string
  end
end
