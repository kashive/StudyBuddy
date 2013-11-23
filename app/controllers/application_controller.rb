class ApplicationController < ActionController::Base
  	protect_from_forgery
   # This is our new function that comes before Devise's one
	before_filter :authenticate_user_from_token!
	# This is Devise's authentication
	before_filter :authenticate_user!
  
  def after_sign_in_path_for(user)
  	# redirecting to the logged in user's courses index page
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
