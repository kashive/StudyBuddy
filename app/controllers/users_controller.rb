class UsersController < ApplicationController
	skip_before_filter :authenticate_user!, :authenticate_user_from_token!
	respond_to :json

	def destroy
		@user = User.find(params[:id])
		Devise.sign_out_all_scopes ? sign_out : sign_out(@user)
		@user.destroy
		redirect_to root_path, :notice => "Account Deleted. Thanks For Trying StudyBuddy :)"
	end
	def checkUserExist
		flag = false
		resource = User.find_by_email(params[:user][:email])
		if resource && resource.valid_password?(params[:user][:password])
			sign_in(:user, resource)
	      	resource.ensure_authentication_token
	      	flag = true 
	    end
	    allCourses = resource.getAllCourses
		respond_to do |format|
			if flag == true
        		format.json { render :json=> { :auth_token=> "success", :user_id => resource.id, :courses => allCourses.to_json }, :status => 200}
        	else
        		format.json { render :json=> { :auth_token=> "failure" }}
        	end
      	end
	end
end