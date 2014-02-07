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
  		Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{parameters[1].split('/')[-1]}' AND action = 'user_join'").each do |notification|
  			notification.seen = true
  			notification.save
  		end
  	elsif parameters[0].include?("invited")
      study_session_id = parameters[1].split('/')[-1]
      invitation_id = Invitation.where("user_id = '#{parameters[1][7]}' AND study_session_id= '#{parameters[1].split('/')[-1]}'").first.id
  		Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{invitation_id}' AND action = 'invited'").each do |notification|
  			notification.seen = true
  			notification.save
  		end
    elsif parameters[0].include?("attending")
      Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{parameters[1].split('/')[-1]}' AND action = 'rsvp_yes'").each do |notification|
        notification.seen = true
        notification.save
      end
  	elsif parameters[0].include?("2 hours")
      Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{parameters[1].split('/')[-1]}' AND action = 'session_2_hour_update'").each do |notification|
        notification.seen = true
        notification.save
      end
    elsif parameters[0].include?("24 hours")
      Notification.where("user_id = '#{parameters[1][7]}' AND notifiable_id = '#{parameters[1].split('/')[-1]}' AND action = 'session_24_hour_update'").each do |notification|
        notification.seen = true
        notification.save
      end
    end
  	respond_to do |format|
      format.json { render json: {} }
    end
  end
end
