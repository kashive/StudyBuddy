class SchedulesController < ApplicationController

  # GET /schedules/new
  # GET /schedules/new.json
  def new
    @courses = Course.where("user_id='#{current_user.id}'")
    @user = current_user
    @toCheckOff = []
    Schedule.where("user_id = '#{current_user.id}'").each do |schedule|
      @toCheckOff.push(schedule.day + " " + schedule.start_time.to_s + "-" + schedule.end_time.to_s + " " + schedule.status.to_s)
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
    Schedule.where("user_id = '#{current_user.id}' AND course_id is NULL").each do |schedule| 
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
  # efficient algorithm
    # get all the non course record for the user
    # go through the dataArray like you currently do
    # interpret the info
    # search all the day records to see if it exactly matches the info we got
    # if it doesn't match then update that specfic record
    # if it matches then continue loop; do nothing

  def updateRecord(allUserSchedule, recordToUpdate)
    allUserSchedule.each do |fromDatabase|
      if fromDatabase.user_id == recordToUpdate.user_id.to_s && fromDatabase.day == recordToUpdate.day && fromDatabase.start_time == recordToUpdate.start_time && fromDatabase.end_time == recordToUpdate.end_time
        if fromDatabase.status != recordToUpdate.status
          fromDatabase.status = recordToUpdate.status
          fromDatabase.save
        end
      end
    end
  end

  def update_schedule
    times = [["12am","1am","2am","3am", "4am", "5am", "6am", "7am", "8am"], ["8am","9am", "10am", "11am", "12pm","1pm", "2pm", "3pm", "4pm"], ["4pm","5pm", "6pm", "7pm", "8pm" , "9pm","10pm", "11pm", "12am"]]
    allUserSchedule = Schedule.where("user_id = '#{current_user.id}' AND course_id is NULL")
    dataArray = params[:data]
    dataArray.each do |data|
      # red-box_Monday_02
      # red-box means busy
      # Monday means day is monday
      # 0 means first column, ie timing is 4pm - 5pm
      # 2 means that it is in the time frame 4pm-8pm
      timesCategoryIndex = data.split("").last(2)[1].to_i;
      timeIndex = data.split("").last(2)[0].to_i;
      start_time = times[timesCategoryIndex][timeIndex]
      end_time = times[timesCategoryIndex][timeIndex + 1]
      day = data.split('_')[1]
      status = ""
      if data.split('_')[0] == "red-box"
        status = "busy"
      elsif data.split('_')[0] == "green-box"
        status = "available"
      elsif  data.split('_')[0] == "white-box"
        status = "none"
      end
      recordToUpdate = Schedule.new("user_id" => current_user.id,
                                        "day" => day,
                                        "start_time"=> start_time,
                                        "end_time"=>end_time,
                                        "status"=>status)
      # this method compares all the records int he schedule and then updates the record
      updateRecord(allUserSchedule, recordToUpdate)
    end
    flash[:notice] = 'Your schedule has been updated!'
    flash.keep(:notice)
    render json: {}
  end
end