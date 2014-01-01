class CoursesController < ApplicationController
  # GET /courses
  # GET /courses.json
  def index
    @courses = Course.where("user_id='#{current_user.id}'")
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @courses }
    end
  end

  # GET /courses/1
  # GET /courses/1.json
  def show
    @course = Course.find(params[:id])
    @studysessions = @course.study_sessions
    @myStudySessions = StudySession.where("host_id = 'current_user.id' AND course_name = '#{@course.name}'")
    @allstudysessions = StudySession.where("course_name='#{@course.name}'")
    @classmates = @course.getClassmates
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @course }
    end
  end

  # GET /courses/new
  # GET /courses/new.json
  def new
    # make sure that you pass in the list of departments and courses to the views
    @course         = Course.new
    @user           = current_user
    @subjectHash    = Marshal.load (File.binread('script/CourseList1')) 
    gon.subjectHash = @subjectHash
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new(params[:course])
    @course.user_id = params[:user_id]
    alreadyExists = false
    if Course.where("user_id = '#{@course.user_id}' AND name = '#{@course.name}'").first != nil
      alreadyExists = true
    end
    subjectHash    = Marshal.load (File.binread('script/CourseList1'))
    timingHash     = Marshal.load (File.binread('script/CourseTimings'))
    @course.professor = subjectHash[@course.department][@course.name].gsub! /"/, ''
    respond_to do |format|
      if alreadyExists == false
        if @course.save
          # updating the activity table
          @course.create_activity :create, owner: current_user
          # updating the schedule timings
          @schedule = Schedule.where("user_id = '#{@course.user_id}'").first
          @schedule = Schedule.new if @schedule == nil
          @schedule.user_id = current_user
          @schedule.course_id = @course.id
          timingHash[@course.name]['daysInWeek'].each do |day|
            if day == "M"
              @schedule.day = "Monday"
              @schedule.start_time = timingHash[@course.name]['startTime']
              @schedule.end_time   = timingHash[@course.name]['endTime']
              @schedule.save
            elsif day =="T"
              @schedule.day = "Tuesday"
              @schedule.start_time = timingHash[@course.name]['startTime']
              @schedule.end_time   = timingHash[@course.name]['endTime']
              @schedule.save
            elsif day =="W"
              @schedule.day = "Wednesday"
              @schedule.start_time = timingHash[@course.name]['startTime']
              @schedule.end_time   = timingHash[@course.name]['endTime']
              @schedule.save
            elsif day =="Th"
              @schedule.day = "Thursday"
              @schedule.start_time = timingHash[@course.name]['startTime']
              @schedule.end_time   = timingHash[@course.name]['endTime']
              @schedule.save
            elsif day = "F"
              @schedule.day = "Friday"
              @schedule.start_time = timingHash[@course.name]['startTime']
              @schedule.end_time   = timingHash[@course.name]['endTime']
              @schedule.save
            end
          end

          @enrollment = Enrollment.new
          @enrollment.user_id   =  current_user.id
          @enrollment.course_name =  @course.name
          @enrollment.save

          @course.getClassmates.each do |classmate|
            next if classmate.id == current_user.id
            courseForClassmate = Course.where("user_id = '#{classmate.id}' AND name = '#{@course.name}'").first
            notification = courseForClassmate.notifications.create("host_id"=>current_user.id,
                                         "user_id"=>classmate.id,
                                         "action"=> "user_join",
                                         "seen"=>false )
            notificationArray = []
            notificationArray.push(notification)
            toShow = showableNotification(notificationArray)
            sendPushNotification("/foo/#{classmate.id}", toShow)
            # publish the notification record to the channel
            # when the channel receives the message the channel is going to forward the message
            # to the user, if the user is suscribe
            # if the user is not suscribed then don't do anything
          end
          format.html { redirect_to user_course_path(current_user,@course), notice: 'Course was successfully created.' }
          format.json { render json: @course, status: :created, location: @course }
        else
          format.html { redirect_to dashboard_path(current_user), alert: 'Error occured. Did you try adding more than 6 courses?' }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to dashboard_path(current_user), alert: 'Course already exists' }
      end
    end
  end

  # PUT /courses/1
  # PUT /courses/1.json
  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(params[:course])
        format.html { redirect_to user_course_path(current_user,@course), notice: 'Course was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /courses/1
  # DELETE /courses/1.json
  def destroy
    @course = Course.find(params[:id])
    enrollments = Enrollment.where("user_id='#{current_user.id}' AND course_name = '#{@course.name}'")
    enrollments.each do |enrollment| enrollment.destroy end
    @course.create_activity :delete, owner: current_user
    @course.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path(current_user), notice: 'Course was successfully deleted' }
      format.json { head :no_content }
    end
  end
end
