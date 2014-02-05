class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :host_id
      t.string :user_id
      t.string :action
      t.belongs_to :notifiable, polymorphic: true

      t.timestamps
    end
    add_index :notifications, [:notifiable_id, :notifiable_type]
  end
end