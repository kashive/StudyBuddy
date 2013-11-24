class Marketing < ActiveRecord::Base
  attr_accessible :course_id, :email, :inviting_user_id, :status, :study_session_id, :times_contacted
end
