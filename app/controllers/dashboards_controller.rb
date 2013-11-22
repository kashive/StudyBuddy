class DashboardsController < ApplicationController
	def show
		@courses = Course.where("user_id='#{current_user.id}'")
		render "/layouts/dashboard.html.erb"
	end
end