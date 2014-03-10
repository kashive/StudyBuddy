class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :sender_id
      t.string :receiver_id
      t.string :message

      t.timestamps
    end
  end
end
