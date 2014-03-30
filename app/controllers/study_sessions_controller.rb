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

  def destroy
    @studysession = StudySession.find(params[:id])
    course = @studysession.getCourse
    @studysession.getYes.each do |rsvpYesUser|
      next if rsvpYesUser.id == current_user.id
      notification = course.notifications.create("host_id"=>current_user.id,
                                                       "user_id"=>rsvpYesUser.id,
                                                       "action"=> "session_delete",
                                                       "seen"=>false )
    end
    @studysession.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path(current_user), notice: 'Study Session was successfully deleted' }
      format.json { head :no_content }
    end
  end
  
  def show
    @studysession = StudySession.find(params[:id])
    @course = @studysession.getCourse
  end

  def edit
    @studysession = StudySession.find(params[:id])
    @user = current_user
    @course = @studysession.getCourse
  end

  def update
    @studysession = StudySession.find(params[:id])
    course = @studysession.getCourse
    @studysession.title = params[:title]
    @studysession.description = params[:description]
    @studysession.location = params[:location]
    @studysession.category = params[:category]
    @studysession.host_id = current_user.id
    if params[:time] != ""
      @studysession.time = DateTime.parse(Time.strptime(params[:time], '%m/%d/%Y %H:%M:%S %P').to_s) 
    end
    @studysession.course_id = course.id
    @studysession.course_name = course.name 
    respond_to do |format|
      if @studysession.save
        @studysession.getYes.each do |rsvpYesUser|
          next if rsvpYesUser.id == current_user.id
          notification = @studysession.notifications.create("host_id"=>current_user.id,
                                                           "user_id"=>rsvpYesUser.id,
                                                           "action"=> "session_update",
                                                           "seen"=>false )
        end
        format.html { redirect_to user_course_study_session_path(current_user,course,@studysession), notice: 'Study Session was successfully updated.'}
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

	def new
  	@studysession  = StudySession.new
    @user = current_user
    @course = Course.find(params[:course_id])
    locationsArray = []
    StudySession.all.each do |ss| locationsArray.push(ss.location) end
    gon.locations = locationsArray.uniq.join(',')
	end

  def updateInvitation
    invitation = Invitation.where("user_id = '#{params[:user_id]}' AND course_id = '#{params[:course_id]}' AND study_session_id = '#{params[:id]}'").first
    study_session = StudySession.where("id = '#{params[:id]}'").first
    if invitation == nil
      invitation = Invitation.create("user_id"=>params[:user_id],
                                     "course_id"=> params[:course_id],
                                     "study_session_id"=>params[:id],
                                     "status"=>"invited",
                                     "host_id"=>study_session.host_id)
    end
    if params[:status] == "yes"
      invitation.status = "yes"
      study_session.create_activity :rsvp, owner: current_user
      notification = study_session.notifications.create("host_id"=>current_user.id,
                                                       "user_id"=>study_session.host_id,
                                                       "action"=>"rsvp_yes",
                                                       "seen"=>false
                                                       )
    end
    invitation.status = "no" if params[:status] == "no"
    invitation.save
    redirect_to user_course_study_session_path(current_user,params[:course_id],params[:id]), notice: 'RSVP updated!'
  end

	def create
    # getting all user_id of all the classmates that were invited to this study session
    invitedClassmates = []
    params.each do |k,v|
      if v == "yes"
        invitedClassmates.push(k)
      end
    end
  	@studysession  = StudySession.new(:title => params[:title], :description => params[:description], :location => params[:location], :category => params[:study_session][:category], :host_id => current_user.id)
    @studysession.time = DateTime.strptime(params[:time], '%m/%d/%Y %H:%M:%S %P') if params[:time] != ""
  	@studysession.course_id = params[:course_id]
    @studysession.twoHourReminder = false
    @studysession.twentyFourHourReminder = false
    if params[:is_private] == "1"
      @studysession.is_private = true
    elsif params[:is_private] == "0"
      @studysession.is_private = false
    end
    @course = Course.find(params[:course_id])
    @user = current_user
    @studysession.course_name = @course.name 
		if @studysession.save
      @studysession.create_activity :create, owner: current_user
      invitedClassmates.each do |classmateId|
        invitation = Invitation.create("host_id"=>current_user.id,
                          "user_id"=>classmateId,
                          "course_id"=>@course.id,
                          "study_session_id"=>@studysession.id,
                          "status"=>"invited")

        notification = invitation.notifications.create("host_id"=>current_user.id,
                                                       "user_id"=>classmateId,
                                                       "action"=> "invited",
                                                       "seen"=>false)
      end
  		redirect_to user_course_study_session_path(current_user,params[:course_id],@studysession.id ), notice: 'Study Session was successfully created. Notifications sent to all invited classmates'
		else  
			render action: :new
	  end
  end
end
