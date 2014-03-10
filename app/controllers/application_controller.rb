class ApplicationController < ActionController::Base
 	protect_from_forgery
   # This is our new function that comes before Devise's one
	before_filter :authenticate_user_from_token!
	# This is Devise's authentication
	before_filter :authenticate_user!

  before_filter :gon_current_user

  helper_method :getAllNotifications, :numberOfUnseenNotifications, :getAllCourses, :checkIfAlreadyOnline
  
  def after_sign_in_path_for(user)
  	dashboard_path(user)
  end

  def getAllNotifications
    Notification.showableNotification(Notification.where("user_id = '#{current_user.id}'").order("created_at desc"))
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


  def getTimingRecommendation
    dayTimeAndPopularity = Hash.new { |hash, key| hash[key] = {} }
    classmates = params[:data]
    # inserting the current user as we need to their schedule in account to
    classmates.push(current_user.id)
    classmates.each do |classmateId|
      Schedule.where("user_id = 'classmateId' AND status = 'available'").each do |schedule|
        time = schedule.start_time + "-" + schedule.end_time
        dayTimeAndPopularity[schedule.day][time] = dayTimeAndPopularity[schedule.day][time].to_i + 1
      end
    end
    dayTopChoice = {}
    dayTimeAndPopularity.keys.each do |day|
      dayTopChoice[day] = dayTimeAndPopularity[day].sort_by{|key,value| value}.reverse.first
    end
    
    respond_to do |format|
        format.json { render :json=> { :recommendation=> dayTopChoice }}
    end
  end
  # this function tells us if the user has the chat open
  def checkIfAlreadyOnline
    # check the presence chat channel to see if the current users is subscribed to the channel
    # if the user is then render return true, else return false
    allUsers = Pusher.get('/channels/presence-chat/users')
    allUsers[:users].each do |userHash|
      return true if userHash.first.last == current_user.id
    end
    return false
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