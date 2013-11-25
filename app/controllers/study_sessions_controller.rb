class StudySessionsController < ApplicationController

	def index
    @all_study_sessions = []
    @all_user_courses = Course.where("user_id = '#{current_user.id}'")
    @all_user_courses.each do |course|
      StudySession.where("course_name = '#{course.name}'").each do |study_session|
		    @all_study_sessions.push(study_session)
      end
    end
	end

  	def new 
    	@studysession  = StudySession.new
  	end

	def create
    	@studysession  = StudySession.new(:title => params[:title], :description => params[:description], :location => params[:location])
    	@studysession.course_id = params[:course_id]  
      @studysession.course_name = Course.find(params[:course_id]).name 
    	respond_to do |format|
      		if @studysession.save
        		format.html { redirect_to user_course_path(current_user,params[:course_id] ), notice: 'Study Session was successfully created.' }
      		else  
      			format.html { render action: "new" }
    		end
    	end
    end
end
