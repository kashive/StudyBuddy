class AddColumsToUser < ActiveRecord::Migration
  def change
  	add_column :users, :first_name, 			:string
  	add_column :users, :last_name, 				:string
  	add_column :users, :college, 				:string
  	add_column :users, :major_minors, 			:string	
  	add_column :users, :exp_graduation_date, 	:string
  	add_column :users, :gender, 				:string	
  	add_column :users, :highschool, 			:string
  	add_column :users, :about_yourself, 		:string
  	add_column :users, :contact_number, 		:string
  end
end