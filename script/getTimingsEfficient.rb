# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'debugger'
require 'sanitize'

def letter?(lookAhead)
  lookAhead =~ /[[:alpha:]]/
end

def numeric?(lookAhead)
  lookAhead =~ /[[:digit:]]/
end

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

courseTimings = {}
subjectCourseTiming = {}

a.get('http://www.brandeis.edu/registrar/schedule/search?strm=1141&view=all') do |searchPage|
	searchForm 	= searchPage.form_with(:id => "searchForm")
	subjectField = searchForm.field_with(:name => "subject")
	allSubjectOptions = subjectField.options;
	# selecting all subject options and looping through it
	allSubjectOptions.each do |subject|
		indexToSelect = allSubjectOptions.index(subject)
		allSubjectOptions[indexToSelect].tick
		coursePage = searchForm.submit(searchForm.buttons[1])
		allSubjectOptions[indexToSelect].untick
		courseHTML = Nokogiri::HTML(coursePage.body)
		# #iterating over the courses table
		courseHTML.xpath('//table[@id="classes-list"]/tr').collect do |row|
			classNumber = row.at("td[2]/a/text()").to_s.split.join(" ")
			puts classNumber
			courseTiming = row.at("td[4]").to_s.gsub(/\s+/," ")
			courseTiming == "" || courseTiming == "<td> TBD </td>"
			dayTime = []
			days = []
			endTime = ""
			startTime = ""
			toInclude = false
			including = ["M","T","W","h","F", "A", "P",":","0","1","2","3","4","5","6","7","8","9","–"]
			charArray = Sanitize.clean(courseTiming).split("")
			charArray.each_with_index do |char, indx|
				if including.include?(char)
					toInclude = true
					if char == ":" && !charArray[indx + 1].numeric?
						toInclude = false
					end
				end
				dayTime.push(char) if toInclude == true
			end
			# dayTime.each_with_index do |char, indx|
			# 	next if indx == 0 && (char.numeric? || char == ":") 
			# 	if char == "T" && dayTime[indx + 1] == "h"

			# end
			puts dayTime.inspect
			puts "--------------------"
		end
	end
end