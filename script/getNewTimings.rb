# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'debugger'
require 'sanitize'

def extractAndPush(times, dayTime, startTime, endTime)
	times.each do |time|
		endTime = Sanitize.clean(time).strip.split("–")[1]
		startTime =  Sanitize.clean(time).strip.split("–")[0].split(' ')[1..2].join(' ')
		timing = startTime + "-" + endTime
		Sanitize.clean(time).strip.split("–")[0].split(',').each do |day|
			timesArray = [timing]
			if dayTime[day.split(' ')[0]] == nil
				dayTime[day.split(' ')[0]] = timesArray
			else
				dayTime[day.split(' ')[0]].push(timing)
			end
		end
	end
end

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

subjectCourseTiming = {}

a.get('http://www.brandeis.edu/registrar/schedule/search?strm=1141&view=all') do |searchPage|
	searchForm 	= searchPage.form_with(:id => "searchForm")
	subjectField = searchForm.field_with(:name => "subject")
	allSubjectOptions = subjectField.options;
	# selecting all subject options and looping through it
	allSubjectOptions.each do |subject|
		puts subject
		indexToSelect = allSubjectOptions.index(subject)
		allSubjectOptions[indexToSelect].tick
		coursePage = searchForm.submit(searchForm.buttons[1])
		allSubjectOptions[indexToSelect].untick
		paginationNumber = coursePage.links_with(:dom_class => "pagenumber").size / 2
		paginationNumber = 1 if paginationNumber == 0
		paginationNumber.times do |num|
			if num > 0
				coursePage = a.get(coursePage.uri.to_s + (num+1).to_s)
			end
			courseHTML = Nokogiri::HTML(coursePage.body)
			# #iterating over the courses table
			courseHTML.xpath('//table[@id="classes-list"]/tr').collect do |row|
				classNumber = row.at("td[2]/a/text()").to_s.split.join(" ")
				courseTiming = row.at("td[4]").to_s.gsub(/\s+/," ")
				dayTime = {}
				endTime = ""
				startTime = ""
				#format => "<td> Block G <br> M,W,Th 2:00 PM - 4:00 PM </td>"
				if courseTiming.split('<br>').size == 2 && courseTiming.split('Block').size == 2
					times = [Sanitize.clean(courseTiming.split('<br>')[1]).strip]
					extractAndPush(times,dayTime, startTime, endTime)
				elsif courseTiming == "" || courseTiming == "<td> TBD </td>"
					next
				elsif courseTiming.split('<br>').size == 1 && courseTiming.split('<hr>').size == 2 && courseTiming.split('Block').size == 1
					times = [Sanitize.clean(courseTiming.split('<hr>')[0]).strip, Sanitize.clean(courseTiming.split('<hr>')[1]).strip]
					extractAndPush(times,dayTime, startTime, endTime)
				elsif courseTiming.split('<br>').size == 1 && courseTiming.split('<hr>').size == 1 && courseTiming.split('Block').size == 1
					times = [Sanitize.clean(courseTiming.split('<br>')[0]).strip]
					extractAndPush(times,dayTime, startTime, endTime)
				# "<td> Block C <br> M,W,Th 10:00 AM–10:50 AM <hr> Block G <br> T,F 9:30 AM–10:50 AM </td>"	
				elsif courseTiming.split('<br>').size == 3 && courseTiming.split('<hr>').size == 2 && courseTiming.split('Block').size == 3
					times = [courseTiming.split('<br>')[1].split('<hr>')[0].strip, Sanitize.clean(courseTiming.split('<br>').last).strip]
					extractAndPush(times,dayTime, startTime, endTime)
				# "<td> <strong>Lecture:</strong> <br> Block C <br> M,W,Th 10:00 AM–10:50 AM <hr> <strong>Recitation:</strong> <br> Th 6:30 PM–7:50 PM </td>"
				elsif courseTiming.split('<strong>').size == 3 && courseTiming.split('<br>').size == 4 && courseTiming.split('<hr>').size == 2
					times = [courseTiming.split('<hr>')[0].split('<br>').last.strip, Sanitize.clean(courseTiming.split('<hr>')[1].split('<br>').last).strip]
					extractAndPush(times,dayTime, startTime, endTime)
				# "<td> Block N <br> T,Th 2:00 PM–3:20 PM <hr> <strong>Recitation:</strong> <br> T 6:30 PM–8:20 PM </td>"
				elsif courseTiming.split('<strong>').size == 2 && courseTiming.split('<br>').size == 3 && courseTiming.split('<hr>').size == 2
					times = [courseTiming.split('<hr>')[0].split('<br>').last.strip, Sanitize.clean(courseTiming.split('<hr>')[1].split('<br>').last).strip]
					extractAndPush(times,dayTime, startTime, endTime)
				end
				subjectCourseTiming[classNumber] = dayTime
				# puts "#{classNumber} => #{dayTime}"
				# puts "----------------------------"
			end
		end
	end
end

File.open('CourseTimingsSpring','w') do|file|
 Marshal.dump(subjectCourseTiming, file)
end