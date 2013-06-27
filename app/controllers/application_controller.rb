class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def after_sign_in_path_for(user)
  	# redirecting to the logged in user's courses index page
  	user_courses_path(user)
  end

end
