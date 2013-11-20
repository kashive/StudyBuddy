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
    allEnrollments = Enrollment.where("course_name='#{@course.name}'")
    @classmates = []
    allEnrollments.each do |enrollment|
      @classmates.push(User.where("id='#{enrollment.user_id}'").first)
    end
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
    scheduleTable  = {"00:00 - 01:00" => "one","01:00 - 02:00" => "two","02:00 - 03:00" => "three","03:00 - 04:00" => "four","04:00 - 05:00" => "five","05:00 - 06:00" => "six","06:00 - 07:00" => "seven","07:00 - 08:00" => "eight","08:00 - 09:00" => "nine","09:00 - 10:00" => "ten","10:00 - 11:00" => "eleven","11:00 - 12:00" => "twelve","12:00 - 13:00" => "thirteen","13:00 - 14:00" => "fourteen","14:00 - 15:00" => "fifteen","15:00 - 16:00" => "sixteen","16:00 - 17:00" => "seventeen","17:00 - 18:00" => "eighteen","18:00 - 19:00" => "nineteen","19:00 - 20:00" => "twenty","20:00 - 21:00" => "twentyone","21:00 - 22:00" => "twentytwo","22:00 - 23:00" => "twentythree","23:00 - 24:00" => "twentyfour"}
    @course.professor = subjectHash[@course.department][@course.name].gsub! /"/, ''
    respond_to do |format|
      if alreadyExists == false
        if @course.save
          # updating the schedule timings
            timesToUpdate = []
            startTime = timingHash[@course.name]['startTime']
            endTime = timingHash[@course.name]['endTime']
            militaryStartTime = DateTime.parse(startTime).strftime("%H:%M")
            militaryEndTime   = DateTime.parse(endTime).strftime("%H:%M")

            timesToUpdate.push(militaryStartTime + " - " + ((militaryStartTime[0..1].to_i + 1).to_s + ":00"))
            if militaryEndTime[3..-1] == "20"
              timesToUpdate.push(militaryEndTime[0..1] + ":00" + " - " + ((militaryEndTime[0..1].to_i + 1).to_s + ":00"))
            end
          timingHash[@course.name]['daysInWeek'].each do |day|
            if day == "M"
              timesToUpdate.each do |time|
                methodName = scheduleTable[time]
                if methodName != nil
                  @monday = Monday.where("user_id = '#{current_user.id}'").first
                  @monday = Monday.new if @monday == nil 
                  @monday.send(methodName+"=","0")
                  @monday.user_id = current_user.id
                  @monday.save
                end
              end
            elsif day =="T"
              timesToUpdate.each do |time|
                methodName = scheduleTable[time]
                if methodName != nil
                  @tuesday = Tuesday.where("user_id = '#{current_user.id}'").first
                  @tuesday = Tuesday.new if @tuesday == nil
                  @tuesday.send(methodName+"=","0")
                  @tuesday.user_id = current_user.id
                  @tuesday.save
                end
              end
            elsif day =="W"
              timesToUpdate.each do |time|
                methodName = scheduleTable[time]
                if methodName != nil
                  @wednesday = Wednesday.where("user_id = '#{current_user.id}'").first
                  @wednesday = Wednesday.new if @wednesday == nil
                  @wednesday.send(methodName+"=","0")
                  @wednesday.user_id = current_user.id
                  @wednesday.save
                end
              end
            elsif day =="Th"
              timesToUpdate.each do |time|
                methodName = scheduleTable[time]
                if methodName != nil
                  @thursday = Thursday.where("user_id = '#{current_user.id}'").first
                  @thursday = Thursday.new if @thursday == nil
                  @thursday.send(methodName+"=","0")
                  @thursday.user_id = current_user.id
                  @thursday.save
                end
              end
            elsif day = "F"
              timesToUpdate.each do |time|
                methodName = scheduleTable[time]
                if methodName != nil
                  @friday = Friday.where("user_id = '#{current_user.id}'").first
                  @friday = Friday.new if @friday == nil
                  @friday.send(methodName+"=","0")
                  @friday.user_id = current_user.id
                  @friday.save
                end
              end
            end
          end
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