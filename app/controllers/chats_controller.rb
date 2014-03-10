class ChatsController < ApplicationController
include ActionView::Helpers::DateHelper

layout false
skip_before_filter :verify_authenticity_token
#except for the getOnline, the other methods don't render any html, just send back the json data 

# gives back a list of all online users, there email and the first mutual class
  def getOnline
    @userListAndInfo = {}
    innerHashUserdata = {}
    allUsers = Pusher.get('/channels/presence-chat/users')
    allUsers[:users].each do |userHash|
      # get the user object  from the id and populate the hash
      onlineUser = User.find(userHash["id"])
      # skip the loop if the onlineUser is not a classmate of the current user
      next if !current_user.getAllClassmates.include?(onlineUser)
      innerHashUserdata["email"] = onlineUser.email 
      innerHashUserdata["name"] = onlineUser.first_name + " " + onlineUser.last_name
      innerHashUserdata["commonClass"] = current_user.firstCommonClass(onlineUser.id)
      # getting all the messages between current user and the online user
      allMessages = Message.where("receiver_id = '#{onlineUser.id}' OR 
                                       receiver_id = '#{current_user.id}' AND
                                       sender_id   = '#{current_user.id}' OR
                                       sender_id   = '#{onlineUser.id}'"
                                      ).order("created_at asc")
      innerHashUserdata["messageHistory"] = allMessages
      @userListAndInfo[onlineUser.id] = innerHashUserdata
      innerHashUserdata = {}
    end
  	render "show"
  end
  # gets the chatthread ready for append for the given user id
  # get the common class between chat users
  def getThreadForUser
    allMessages = Message.where("receiver_id = '#{params[:user_id]}' OR 
                                       receiver_id = '#{current_user.id}' AND
                                       sender_id   = '#{current_user.id}' OR
                                       sender_id   = '#{params[:user_id]}'"
                                      ).order("created_at asc")
    sender = User.find(params[:user_id])
    sender_name = sender.first_name + " " + sender.last_name
    initialHTML = "<div class=\"message-thread\" id = \"thread#{params['user_id']}\" style=\"display: none\">"
    middleHTML = ""
    allMessages.each do |message|
      if (message.sender_id == current_user.id.to_s)
        bubble = "left"
        user_name = current_user.first_name + " " + current_user.last_name
      else
        bubble = "right"
        user_name = sender_name
      end
      middleHTML = middleHTML + "<div class=\"message bubble-#{bubble}\"> <label class=\"message-user\">#{user_name}</label> <label class=\"message-timestamp\">#{time_ago_in_words(message.created_at)} ago</label> <p>#{message.message}</p></div>"
    end
    endingHTML = "</div> </div>"
    respond_to do |format|
        format.json { render :json=> { :chatHistory => initialHTML + middleHTML + endingHTML}}
    end
  end

  def getCommonClass
     respond_to do |format|
        format.json { render :json=> { :commonClass => current_user.firstCommonClass(params[:user_id])}}
    end
  end
  
  def create
    receiver_id = params[:receiver_id].split("thread").last
  	# save the message into the database
    Message.create("message" => params[:message].to_s,
                   "sender_id" => current_user.id.to_s,
                   "receiver_id" => receiver_id.to_s
                   )
    # sending a trigger to the receiver of the message
    Pusher['private-chat'+receiver_id].trigger('message', {:message => params[:message], :receiver_id => receiver_id, :sender_id => current_user.id, :sender_name => current_user.first_name + " " + current_user.last_name})
    respond_to do |format|
        format.json { render :json=> { :message => params[:message], 
                                       :receiver_id=>receiver_id,
                                       :sender_id=>current_user.id
                                       }
                    }
    end
  end
end