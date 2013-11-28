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
      course = Course.find(params[:course_id])
      @studysession.course_name = course.name 
    	respond_to do |format|
      		if @studysession.save
            @studysession.create_activity :create, owner: current_user
            course.getClassmates.each do |classmate|
              next if classmate.id == current_user.id
              invitation = Invitation.create("host_id"=>current_user.id,
                                "user_id"=>classmate.id,
                                "course_id"=>course.id,
                                "study_session_id"=>@studysession.id,
                                "status"=>"invited")

              invitation.notifications.create("host_id"=>current_user.id,
                                         "user_id"=>classmate.id,
                                         "action"=> "invited",
                                         "seen"=>false )
            end
        		format.html { redirect_to user_course_path(current_user,params[:course_id] ), notice: 'Study Session was successfully created. Invitations sent to all classmates' }
      		else  
      			format.html { render action: "new" }
    		end
    	end
    end
end
