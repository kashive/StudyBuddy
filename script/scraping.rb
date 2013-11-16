require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'debugger'
# require 'storable'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

# hashes to store the data in
subjectCourseTeacher = {}
courseAndTeacher = {}
courseTimings = {}

a.get('http://www.brandeis.edu/registrar/schedule/search?strm=1133&view=all') do |searchPage|
#algorithm:
# get the search form website, get all the subject values, iterate through each subject,
# get the list of courses in the subject, put it in a hash
	searchForm 	= searchPage.form_with(:id => "searchForm")
	subjectField = searchForm.field_with(:name => "subject")
	allSubjectOptions = subjectField.options;
	# selecting all subject options and looping through it
	allSubjectOptions.each do |subject|
		indexToSelect = allSubjectOptions.index(subject)
		allSubjectOptions[indexToSelect].tick
		subjectName = allSubjectOptions[indexToSelect].text.strip;
		coursePage = searchForm.submit(searchForm.buttons[1])
		allSubjectOptions[indexToSelect].untick
		courseHTML = Nokogiri::HTML(coursePage.body)
		#iterating over the courses table
		courseHTML.xpath('//table[@id="classes-list"]/tr').collect do |row|
			className = row.at("td[3]/strong/text()").to_s.strip;
			teachersName = row.at("td[6]/a/text()").to_s.strip.inspect;
			dayArray = []
			startTime=""
			endTime = ""
			courseTiming = row.at("td[4]").to_s.gsub(/\s+/," ")
			# pp courseTiming.inspect
			if courseTiming.include?('<br>')
				exactStringSplit = courseTiming.split('<br>')[1].strip
				startTime = exactStringSplit.split(',').last.split(' ')[1..-1].join.split('–')[0]
				endTime   = exactStringSplit.split(',').last.split(' ')[1..-1].join.split('–')[1]
				exactStringSplit.split(',').each do |day|
					dayArray.push(day.split(' ')[0])
				end
			end
			timingInfo = {}
			timingInfo['daysInWeek'] = dayArray
			timingInfo['startTime'] = startTime
			timingInfo['endTime'] = endTime
			courseTimings[className] = timingInfo
			timingInfo = {}
			courseAndTeacher[className] = teachersName
		end
		subjectCourseTeacher[subjectName]=courseAndTeacher
		courseAndTeacher = {}
	end
end
# puts courseTimings.inspect
File.open('CourseTimings','w') do|file|
 Marshal.dump(courseTimings, file)
end

File.open('CourseList1','w') do|file|
 Marshal.dump(subjectCourseTeacher, file)
end