# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'debugger'

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

# hashes to store the data in
courseAndTeacher = {}
courseNumberNameTeacher = {}
departmentCourseNumberNameTeacher = {}
courseTimings = {}

a.get('http://www.brandeis.edu/registrar/schedule/search?strm=1141&view=all') do |searchPage|
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
		# #iterating over the courses table
		courseHTML.xpath('//table[@id="classes-list"]/tr').collect do |row|
			className = row.at("td[3]/strong/text()").to_s.strip;
			teachersName = row.at("td[6]/a/text()").to_s.strip;
			courseAndTeacher[className] = teachersName
			classNumber = row.at("td[2]/a/text()").to_s.split.join(" ")
			courseNumberNameTeacher[classNumber] = courseAndTeacher
			courseAndTeacher = {}
		end
		departmentCourseNumberNameTeacher[subjectName] = courseNumberNameTeacher
		courseNumberNameTeacher={}
	end
end

File.open('CourseListSpring','w') do|file|
 Marshal.dump(departmentCourseNumberNameTeacher, file)
end