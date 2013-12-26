class AddHostToStudySessions < ActiveRecord::Migration
  def change
    add_column :study_sessions, :host_id, :string
  end
end
