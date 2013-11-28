class NotificationsController < ApplicationController
  def index
  	Notification.where("user_id = '#{current_user.id}'").each do |notification|
  		notification.seen = true
  		notification.save
  	end
  	respond_to do |format|
      format.html # index.html.erb
    end
  end

  def seen
  	parameters = params[:data].split(",")
  	if parameters[0].include?("joined")
  		Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{parameters[1][-1]}' AND action = 'user_join'").each do |notification|
  			notification.seen = true
  			notification.save
  		end
  	elsif parameters[0].include?("invited")
  		Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{parameters[1][-1]}' AND action = 'invited'").each do |notification|
  			notification.seen = true
  			notification.save
  		end
  	end
  	respond_to do |format|
      format.json { render json: {} }
    end
  end
end
