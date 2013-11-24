class StudySessionsController < ApplicationController

	def index
		# get each session for every course in a array
		@all_study_sessions = current_user.study_sessions
	end

  	def new 
    	@studysession  = StudySession.new
  	end

	def create
    	@studysession  = StudySession.new(:title => params[:title], :description => params[:description], :location => params[:location])
    	@studysession.course_id = params[:course_id]  
    	respond_to do |format|
      		if @studysession.save
        		format.html { redirect_to user_course_path(current_user,params[:course_id] ), notice: 'Study Session was successfully created.' }
      		else  
      			format.html { render action: "new" }
    		end
    	end
    end
end
