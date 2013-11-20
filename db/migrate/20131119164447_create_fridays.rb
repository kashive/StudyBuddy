class CreateFridays < ActiveRecord::Migration
  def change
    create_table :fridays do |t|
      t.string :user_id
      t.string :zero
      t.string :one
      t.string :two
      t.string :three
      t.string :four
      t.string :five
      t.string :six
      t.string :seven
      t.string :eight
      t.string :nine
      t.string :ten
      t.string :eleven
      t.string :twelve
      t.string :thirteen
      t.string :fourteen
      t.string :fifteen
      t.string :sixteen
      t.string :seventeen
      t.string :eighteen
      t.string :nineteen
      t.string :twenty
      t.string :twentyone
      t.string :twentytwo
      t.string :twentythree
      t.string :twentyfour

      t.timestamps
    end
  end
end
