class CreateStudySessions < ActiveRecord::Migration
  def change
    create_table :study_sessions do |t|
      t.text :title
      t.string :category
      t.time :time
      t.date :date
      t.string :location
      t.text :description

      t.timestamps
    end
  end
end
