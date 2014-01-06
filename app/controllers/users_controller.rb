class UsersController < ApplicationController
	def destroy
		@user = User.find(params[:id])
		Devise.sign_out_all_scopes ? sign_out : sign_out(@user)
		@user.destroy
		redirect_to root_path, :notice => "Account Deleted. Thanks For Trying StudyBuddy"
	end
end