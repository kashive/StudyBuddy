task :send_twenty_four_hour_reminders => :environment do
	oneDayFromNow = Time.now + (3600*24)
  # get me all the events that are happening in between Time.now and 24 hours from now that I haven't sent a 24 hour reminder to already
	StudySession.where("time > '#{Time.now}' AND time <= '#{oneDayFromNow}' AND \"twoHourReminder\" = 'false'").each do |studySession|
      studySession.sendReminder(24) 
		  studySession.twentyFourHourReminder = true
      studySession.save
  end
end

task :send_two_hours_reminder => :environment do
	twoHoursFromNow = Time.now + (3600*2)
	StudySession.where("time > '#{Time.now}' AND time <= '#{twoHoursFromNow}' AND \"twoHourReminder\" = 'false'").each do |studySession|
      studySession.sendReminder(2)
      studySession.twoHourReminder = true
      studySession.save
  end
end