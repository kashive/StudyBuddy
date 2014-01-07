task :send_twenty_four_hour_reminders => :environment do
	oneDayFromNow = Time.now + (3600*24)
  # get me all the events that are happening in between Time.now and 24 hours from now that I haven't sent a 24 hour reminder to already
  	StudySession.where("time >= '#{oneDayFromNow}'").each do |studySession|
  		studySession.sendReminder(24)
  		studySession.twoHourReminder = true
  	end
end

task :send_two_hours_reminder => :environment do
	twoHoursFromNow = Time.now + (3600*2)
	StudySession.where("time >= '#{twoHoursFromNow}'").each do |studySession|
  		studySession.sendReminder(2)
  		studySession.twentyFourHourReminder = true
  	end
end