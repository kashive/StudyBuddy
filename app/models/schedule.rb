class Schedule < ActiveRecord::Base
  attr_accessible :course_id, :day, :end_time, :start_time, :user_id, :status
end
