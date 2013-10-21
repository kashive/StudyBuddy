class AddDepartmentToCourse < ActiveRecord::Migration
  def change
  	add_column :courses, :department, :string
  end
end
