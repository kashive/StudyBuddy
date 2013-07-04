class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.belongs_to :user
      t.belongs_to :course

      t.timestamps
    end
  end
end
