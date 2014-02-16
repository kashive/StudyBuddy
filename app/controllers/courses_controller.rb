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
    @myStudySessions = StudySession.where("host_id = '#{current_user.id}' AND course_name = '#{@course.name}'")
    @allstudysessions = StudySession.where("course_name = '#{@course.name}' AND is_private is NULL OR is_private is FALSE") - @myStudySessions
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
    @subjectHash    = Marshal.load (File.binread('script/CourseListSpring')) 
    gon.subjectHash = @subjectHash
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @course }
    end
  end

  def putIntoDatabase(day,course,time)
    # modifying time so that the database remains uniform
    startTimePMAM = time.split('-')[0].split(' ')[1]
    endTimePMAM = time.split('-')[1].split(' ')[1]
    startTimeFirstNumber = time.split('-')[0].split(' ')[0].split(':')[0]
    startTimeSecondNumber = time.split('-')[0].split(' ')[0].split(':')[1]
    endTimeFirstNumber = time.split('-')[1].split(' ')[0].split(':')[0]
    endTimeSecondNumber = time.split('-')[1].split(' ')[0].split(':')[1]

    if startTimeSecondNumber.to_i == 0 && endTimeSecondNumber.to_i == 50
      start_time = startTimeFirstNumber + startTimePMAM.downcase
      end_time = (endTimeFirstNumber.to_i + 1).to_s + endTimePMAM.downcase
      Schedule.create("user_id" => current_user.id,
                      "day" => day,
                      "course_id" => course.id,
                      "start_time"=> start_time,
                      "end_time"=>end_time,
                      "status"=>"busy")  
    else
      start_time = startTimeFirstNumber + startTimePMAM.downcase
      end_time = endTimeFirstNumber + endTimePMAM.downcase
      Schedule.create("user_id" => current_user.id,
                      "day" => day,
                      "course_id" => course.id,
                      "start_time"=> start_time,
                      "end_time"=>end_time,
                      "status"=>"busy")
      start_time = endTimeFirstNumber + endTimePMAM.downcase
      end_time = (endTimeFirstNumber.to_i + 1).to_s + endTimePMAM.downcase
      Schedule.create("user_id" => current_user.id,
                    "day" => day,
                    "course_id" => course.id,
                    "start_time"=> start_time,
                    "end_time"=>end_time,
                    "status"=>"busy")    
    end
  end

  # POST /courses
  # POST /courses.json
  def create
    @course = Course.new
    subjectHash    = Marshal.load (File.binread('script/CourseListSpring'))
    timingHash     = Marshal.load (File.binread('script/CourseTimingsSpring'))
    @course.department = params[:course][:department]
    number = params[:course][:name].to_s
    if number != ""
      number = number + " 1" if !"234".include?(number[-1])
      @course.course_number = number
      @course.name = subjectHash[@course.department][number].keys.first
      @course.user_id = params[:user_id]
      @course.professor = subjectHash[@course.department][number][@course.name]
      @course.term = "Spring 2014"
    end
    alreadyExists = false
    if Course.where("user_id = '#{@course.user_id}' AND name = '#{@course.name}'").first != nil
      alreadyExists = true
    end
    respond_to do |format|
      if alreadyExists == false
        if @course.save
          # updating the activity table
          @course.create_activity :create, owner: current_user
          timingHash[number].each do |day, times|
            if day == "M"
              times.each do |time|
                putIntoDatabase("Monday",@course,time)
              end
            elsif day =="T"
              times.each do |time|
                putIntoDatabase("Tuesday",@course,time)
              end
            elsif day =="W"
              times.each do |time|
                putIntoDatabase("Wednesday",@course,time)
              end
            elsif day =="Th"
              times.each do |time|
                putIntoDatabase("Thursday",@course,time)
              end
            elsif day = "F"
              times.each do |time|
                putIntoDatabase("Friday",@course,time)
              end
            end
          end
      
          @enrollment = Enrollment.new
          @enrollment.user_id   =  current_user.id
          @enrollment.course_name =  @course.name
          @enrollment.course_id = @course.id
          @enrollment.save
          @course.enrollment_id = @enrollment.id
          @course.save

          @course.getClassmates.each do |classmate|
            next if classmate.id == current_user.id
            courseForClassmate = Course.where("user_id = '#{classmate.id}' AND name = '#{@course.name}'").first
            notification = courseForClassmate.notifications.create("host_id"=>current_user.id,
                                         "user_id"=>classmate.id,
                                         "action"=> "user_join",
                                         "seen"=>false )
          end
          format.html { redirect_to user_course_path(current_user,@course), notice: 'Course was successfully created.' }
          format.json { render json: @course, status: :created, location: @course }
        else
          format.html { redirect_to dashboard_path(current_user), alert: "Error occured. Did you try adding more than 6 courses? or not select a course" }
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
    @course.create_activity :delete, owner: current_user
    @course.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path(current_user), notice: 'Course was successfully deleted.' }
      format.json { head :no_content }
    end
  end
end