class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :term
      t.string :professor
      t.string :number

      t.timestamps
    end
  end
end
