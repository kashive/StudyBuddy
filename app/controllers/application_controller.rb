class ApplicationController < ActionController::Base
 	protect_from_forgery
   # This is our new function that comes before Devise's one
	before_filter :authenticate_user_from_token!
	# This is Devise's authentication
	before_filter :authenticate_user!

  before_filter :gon_current_user

  helper_method :getAllNotifications, :numberOfUnseenNotifications, :getAllCourses
  
  def after_sign_in_path_for(user)
  	dashboard_path(user)
  end

  def destroyUser
  	# delete all the courses of the user
  	# delete all the enrollments of the user
	  	Enrollment.where("user_id = '#{current_user.id}'").each do |enrollment| enrollment.destroy end
	  	Course.where("user_id = '#{current_user.id}'").each do |course| course.destroy end
	  	user = User.where("id= '#{current_user.id}'").first
	  	signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource))
	  	user.destroy
	  	format.html { redirect_to root_path, notice: 'Account deleted' }
	end

  def gon_current_user
    if current_user != nil
      gon.logged_user = current_user
    else
      gon.logged_user = 0
    end
  end

  def sendPushNotification(url, data)
    require 'eventmachine'
    EM.run {
      client = Faye::Client.new('http://0.0.0.0:9292/faye')
      publication= client.publish(url, data)
      publication.callback do
        logger.debug "Message received by server! #{url} and data #{data}"
      end

      publication.errback do |error|
        logger.debug 'There was a problem: ' + error.message
      end
    }
  end

	def getAllNotifications
  	showableNotification(Notification.where("user_id = '#{current_user.id}'").order("created_at desc"))
  end

  def showableNotification(notificationArray)
    toShow = {}
    notificationArray.each do |notification|
      hostUser = User.where("id = '#{notification.host_id}'").first
      if notification.action == "user_join"
        course = notification.notifiable
        if course == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has joined a course of yours which has since been deleted"
        else
          receivingUser = User.where("id = '#{notification.user_id}'").first
          courseForReceiver = Course.where("user_id = '#{notification.user_id}' AND name ='#{course.name}'").first
          pathAndTime = []
          pathAndTime.push(user_course_path(receivingUser.id,courseForReceiver.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has joined #{course.name} and is now a classmate"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "invited"
        invitation = notification.notifiable
        if invitation == nil
          pathAndTime=[]
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has invited you to for a study session which has since been deleted"
        else
          studySession = StudySession.where("id = '#{invitation.study_session_id}'").first
          course = Course.where("id = '#{invitation.course_id}'").first
          pathAndTime=[]
          pathAndTime.push(user_course_study_session_path(current_user,course.id, studySession.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} has invited you to join #{studySession.title} for your #{course.name} class"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "rsvp_yes"
        studySession = notification.notifiable
        if studySession == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} was attending a study session which has since been deleted"
        else
          pathAndTime = []
          pathAndTime.push(user_course_study_session_path(current_user,studySession.getCourse.id, studySession.id))
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "#{hostUser.first_name} is attending #{studySession.title}"
        end
        toShow[notificationText] = pathAndTime
      elsif notification.action == "session_delete"
        course = notification.notifiable
        if course == nil
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "A course and study session that you rsvp'ed for is removed"
        else
          pathAndTime = []
          pathAndTime.push("#")
          pathAndTime.push(notification.created_at)
          pathAndTime.push(notification.seen)
          notificationText = "A study session for #{course.name} that you rsvp'ed has been cancelled"
        end
        toShow[notificationText] = pathAndTime
      end
    end
    return toShow
  end

  def numberOfUnseenNotifications
    counter = 0
    getAllNotifications.each do |k,v|
      if v[2] == false
        counter = counter + 1
      end
    end
    return counter
  end

  def getAllCourses
    return Course.where("user_id='#{current_user.id}'")
  end

  private
	def authenticate_user_from_token!
		user_email = params[:user_email].presence
		user = user_email && User.find_by_email(user_email)
	 
		# Notice how we use Devise.secure_compare to compare the token
		# in the database with the token given in the params, mitigating
		# timing attacks.
		if user && Devise.secure_compare(user.authentication_token, params[:user_token])
			sign_in user, store: false
		end
	end

end
