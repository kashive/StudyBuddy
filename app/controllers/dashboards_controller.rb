class DashboardsController < ApplicationController
	def show
		@courses = Course.where("user_id='#{current_user.id}'")		
		size = 8
		if @courses.size < 4
			size = @courses.size * 2
		end
		@activities = PublicActivity::Activity.order("created_at desc").page(params[:page]).per(size)
		render "/layouts/dashboard.html.erb"
	end
end