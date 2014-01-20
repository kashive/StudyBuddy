class RegistrationsController < Devise::RegistrationsController	
  def create
  	a = super
  	if a.size == 86 || a.size == 92
  		@user = User.order("created_at desc").first
  		@user.create_activity :create, owner: @user
      days  = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
      times = ["12am-1am","1am-2am","2am-3am", "3am-4am", "4am-5am", "5am-6am", "6am-7am", "7am-8am", "8am-9am", "9am-10am", "10am-11am", "11am-12pm","12pm-1pm", "1pm-2pm", "2pm-3pm", "3pm-4pm", "4pm-5pm","5pm-6pm","6pm-7pm","7pm-8pm","8pm-9pm" ,"9pm-10pm","10pm-11pm", "11pm-12am"]
      days.each do |day|
        times.each do |time|
          Schedule.create("user_id" => @user.id,
                          "day" => day,
                          "start_time"=> time.split('-')[0],
                          "end_time"=> time.split('-')[1],
                          "status"=>"none")
        end
      end
  	end
  end

  protected

	def after_update_path_for(resource)
	  edit_user_registration_path(resource)
	end
end