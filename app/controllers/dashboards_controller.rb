class DashboardsController < ApplicationController
	def show
		@courses = Course.where("user_id='#{current_user.id}'")		
		@activities = PublicActivity::Activity.order("created_at desc").page(params[:page]).per(8)
		render "/layouts/dashboard.html.erb"
	end
end