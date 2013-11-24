class AddEnrollmentIdToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :enrollment_id, :integer
  end
end
