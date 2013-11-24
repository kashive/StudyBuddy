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
<<<<<<< HEAD
    @studysessions = @course.study_sessions
=======
    allEnrollments = Enrollment.where("course_name='#{@course.name}'")
    @classmates = []
    allEnrollments.each do |enrollment|
      @classmates.push(User.where("id='#{enrollment.user_id}'").first)
    end
>>>>>>> master
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
    gon.subjectHash = @subjectHash;
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
          # updating the schedule timings
          @schedule = Schedule.where("user_id = '#{@course.user_id}'").first
          @schedule = Schedule.new if @schedule == nil
          timingHash[@course.name]['daysInWeek'].each do |day|
            if day == "M"
              @schedule.monday = @schedule.monday.to_s + timingHash[@course.name]['startTime'] +"-"+ timingHash[@course.name]['endTime']+","
            elsif day =="T"
              @schedule.tuesday = @schedule.tuesday.to_s + timingHash[@course.name]['startTime'] +"-"+ timingHash[@course.name]['endTime']+","
            elsif day =="W"
              @schedule.wednesday = @schedule.wednesday.to_s + timingHash[@course.name]['startTime'] +"-"+ timingHash[@course.name]['endTime']+","
            elsif day =="Th"
              @schedule.thursday = @schedule.thursday.to_s + timingHash[@course.name]['startTime'] +"-"+ timingHash[@course.name]['endTime']+","
            elsif day = "F"
              @schedule.friday = @schedule.friday.to_s + timingHash[@course.name]['startTime'] +"-"+ timingHash[@course.name]['endTime']+","
            end
          end
          @schedule.user_id = params[:user_id]
          @schedule.save

          @enrollment = Enrollment.new
          @enrollment.user_id   =  current_user.id
          @enrollment.course_name =  @course.name
          @enrollment.save
          format.html { redirect_to user_course_path(current_user,@course), notice: 'Course was successfully created.' }
          format.json { render json: @course, status: :created, location: @course }
        else
          format.html { redirect_to user_courses_path(current_user), alert: 'Error occured. Did you try adding more than 6 courses?' }
          format.json { render json: @course.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to user_courses_path(current_user), alert: 'Course already exists' }
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
    @course.destroy

    respond_to do |format|
      format.html { redirect_to user_courses_path, notice: 'Course was successfully deleted' }
      format.json { head :no_content }
    end
  end
end
