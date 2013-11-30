class SchedulesController < ApplicationController

  # GET /schedules/new
  # GET /schedules/new.json
  def new
    @courses = Course.where("user_id='#{current_user.id}'")
    @user = current_user
    @toCheckOff = []
    Schedule.where("user_id = '#{current_user.id}'").each do |schedule|
      @toCheckOff.push(schedule.day + " " + schedule.start_time.to_s + "-" + schedule.end_time.to_s)
    end

    @schedule = Schedule.new
    @days  = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
    @times = [["12am","1am","2am","3am", "4am", "5am", "6am", "7am", "8am"], ["8am","9am", "10am", "11am", "12pm","1pm", "2pm", "3pm", "4pm"], ["4pm","5pm", "6pm", "7pm", "8pm" , "9pm","10pm", "11pm", "12am"]]
    @tableNumbers = Array(0..2)
    @columnNumbers = Array(0..7)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @schedule }
    end
  end

  # POST /schedules
  # POST /schedules.json
  def create
    Schedule.where("user_id = '#{current_user.id}'").each do |schedule| 
      schedule.destroy 
    end
    params[:time].keys.each do |times|
      @schedule = Schedule.new()
      day = times.split(" ")[0]
      @schedule.user_id = current_user
      @schedule.day = day
      @schedule.start_time =times.split(" ")[1].split('-')[0]
      @schedule.end_time = times.split(" ")[1].split('-')[1]
      @schedule.save
    end
    respond_to do |format|
        format.html { redirect_to new_user_schedule_path(current_user), notice: 'Schedule has been successfully updated' }
    end
  end
end
