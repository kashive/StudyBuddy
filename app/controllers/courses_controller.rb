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
    @subjectHash    = Marshal.load (File.binread('script/CoursesList')) 
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
    subjectHash    = Marshal.load (File.binread('script/CoursesList'))
    @course.professor = subjectHash[@course.department][@course.name].gsub! /"/, ''
    respond_to do |format|
      if @course.save
        @enrollment = Enrollment.new
        @enrollment.user_id   =  current_user.id
        @enrollment.course_name =  @course.name
        @enrollment.save
        format.html { redirect_to user_course_path(current_user,@course), notice: 'Course was successfully created.' }
        format.json { render json: @course, status: :created, location: @course }
      else
        format.html { render action: "new" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
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
