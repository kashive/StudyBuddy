class AddEnrollmentIdToStudySession < ActiveRecord::Migration
  def change
    add_column :study_sessions, :enrollment_id, :integer
  end
end
