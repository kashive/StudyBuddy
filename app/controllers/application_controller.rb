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
      client = Faye::Client.new('http://localhost:9292/faye')
      publication= client.publish(url, data)
      publication.callback do
        logger.debug 'Message received by server!'
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
        pathAndTime = []
        pathAndTime.push(user_course_path(current_user,course))
        pathAndTime.push(notification.created_at)
        pathAndTime.push(notification.seen)
        notificationText = "#{hostUser.first_name} has joined #{course.name} and is now a classmate"
        toShow[notificationText] = pathAndTime
      elsif notification.action == "invited"
        invitation = notification.notifiable
        studySession = StudySession.where("id = '#{invitation.study_session_id}'").first
        course = Course.where("id = '#{invitation.course_id}'").first
        pathAndTime=[]
        pathAndTime.push("#")
        pathAndTime.push(notification.created_at)
        pathAndTime.push(notification.seen)
        notificationText = "#{hostUser.first_name} has invited you to join #{studySession.title} for your #{course.name} class"
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
