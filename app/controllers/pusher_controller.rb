class PusherController < ApplicationController
  protect_from_forgery :except => :auth # stop rails CSRF protection for this action

  	def auth
	    if current_user
	    	privateOrPresence = params[:channel_name].split('-').first
	    	# determining whether the channel that is coming in is a private notification channel or a public presence channel
	    	if privateOrPresence == "private"
			      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
			# return all classmates id list as well
			elsif privateOrPresence == "presence"
				  classmateInfo = {}
				  info = []
				  current_user.getAllClassmates.each do |classmate|
				  	info.push(classmate.email,classmate.first_name + " " + classmate.last_name,classmate.firstCommonClass(classmate.id))
				  	classmateInfo[classmate.id] = info
				  	info = []
				  end
			      response = Pusher[params[:channel_name]].authenticate(params[:socket_id], {
			        :user_id => current_user.id, # => required
			        :user_info => { # => optional - for example
			          :first_name => current_user.first_name,
			          :last_name => current_user.last_name,
			          :email => current_user.email,
			          :allClassmatesId => classmateInfo
			        }
			      })
			end
			if response
				puts response
				render :json => response
			else
				render :text => "Forbidden", :status => '403'
			end	
		else
			render :text => "Forbidden", :status => '403'
	  	end
  	end
end