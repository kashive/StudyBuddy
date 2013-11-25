class AddEnrollmentIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :enrollment_id, :integer
  end
end
