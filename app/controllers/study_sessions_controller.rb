class StudySessionsController < ApplicationController

	def index
		# get each session for every course in a array
		@all_study_sessions = Array.new
		@courses = current_user.courses
		@courses.each do |course|
			study_sessions = course.studysessions
			study_sessions.each do |session| 
				@all_study_sessions.push(session)
			end
		end
	end

  	def new 
    	@study_session  = StudySession.new
  	end

	def create
    	@study_session  = StudySession.new(params[:study_session])
    	@study_session.course_id = params[:course_id]    
    end
end
