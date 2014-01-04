# encoding: utf-8
require 'rubygems'
require 'nokogiri'
require 'mechanize'
require 'debugger'
require 'sanitize'

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
			dayTime = {}
			endTime = ""
			startTime = ""
			if courseTiming.include?('<br>') && !courseTiming.include?('<hr>')
				endTime = Sanitize.clean(courseTiming.split('<br>')[1].strip).split('–')[1].strip
				startTime = Sanitize.clean(courseTiming.split('<br>')[1].strip).split('–')[0].split(' ')[1..2].join(" ")
				Sanitize.clean(courseTiming.split('<br>')[1].strip).split('–')[0].split(',').each do |day|
					dayTime[day.split(' ')[0]] = startTime + "-" + endTime
				end
			elsif courseTiming == "" || courseTiming == "<td> TBD </td>"
				next
			elsif !courseTiming.include?('<br>') && courseTiming.include?('<hr>') && !courseTiming.include?('<strong>')
				courseTiming.split('<hr>').each do |timing|
					endTime = Sanitize.clean(timing.split('–')[1]).strip
					startTime = timing.split('–')[0].split(" ").last(2).join(" ")
					Sanitize.clean(timing).strip.split("–")[0].split(',').each do |day|
						dayTime[day.split(' ')[0]] = startTime + "-" + endTime
					end
				end
			elsif !courseTiming.include?('<br>') && !courseTiming.include?('<hr>') && !courseTiming.include?('<strong>')
				endTime = Sanitize.clean(courseTiming).strip.split("–")[1]
				startTime =  Sanitize.clean(courseTiming).strip.split("–")[0].split(' ')[1..2].join(' ')
				Sanitize.clean(courseTiming).strip.split("–")[0].split(',').each do |day|
					dayTime[day.split(' ')[0]] = startTime + "-" + endTime
				end
			elsif courseTiming.include?('<br>') && courseTiming.include?('<hr>') && !courseTiming.include?('<strong>') &&  courseTiming.split('Block').size != 3
				splittedTime = courseTiming.split('<br>')[1]
				splittedTime.split('<hr>').each do |timing|
					endTime = Sanitize.clean(timing.split('–')[1]).strip
					startTime = timing.split('–')[0].split(" ").last(2).join(" ")
					Sanitize.clean(timing).strip.split("–")[0].split(',').each do |day|
						dayTime[day.split(' ')[0]] = startTime + "-" + endTime
					end
				end
			elsif  courseTiming.split('Block').size == 3
				times = [courseTiming.split('<br>')[1].split('<hr>')[0].strip, Sanitize.clean(courseTiming.split('<br>').last).strip]
				times.each do |time|
					endTime = Sanitize.clean(time).strip.split("–")[1]
					startTime =  Sanitize.clean(time).strip.split("–")[0].split(' ')[1..2].join(' ')
					Sanitize.clean(time).strip.split("–")[0].split(',').each do |day|
						dayTime[day.split(' ')[0]] = startTime + "-" + endTime
					end
				end
			elsif courseTiming.include?('Recitation:') || courseTiming.include?('Lab:')
				times = [courseTiming.split('<hr>')[0].split('<br>').last.strip, Sanitize.clean(courseTiming.split('<hr>')[1].split('<br>').last.strip).strip]
				times.each do |time|
					endTime = Sanitize.clean(time).strip.split("–")[1]
					startTime =  Sanitize.clean(time).strip.split("–")[0].split(' ')[1..2].join(' ')
					Sanitize.clean(time).strip.split("–")[0].split(',').each do |day|
						dayTime[day.split(' ')[0]] = startTime + "-" + endTime
					end
				end
			else
				debugger
			end
			subjectCourseTiming[classNumber] = dayTime
			puts "#{classNumber} => #{dayTime}"
			puts "----------------------------"
		end
	end
end
# # puts courseTimings.inspect
# File.open('CourseTimings1','w') do|file|
#  Marshal.dump(courseTimings, file)
# end


# timing code
# dayArray = []
# 			startTime=""
# 			endTime = ""
# 			courseTiming = row.at("td[4]").to_s.gsub(/\s+/," ")
# if courseTiming.include?('<br>') && !courseTiming.include?('<hr>')
# 				exactStringSplit = courseTiming.split('<br>')[1].strip
# 				startTime = exactStringSplit.split('–')[0].split(' ')[1..-1].join(' ')
# 				endTime   = exactStringSplit.split('–')[1].split(' ')[0..1].join(' ')
# 				exactStringSplit.split(',').each do |day|
# 					dayArray.push(day.split(' ')[0])
# 				end
# 			elsif courseTiming.include?('<hr>')
# 				exactStringSplit = courseTiming.split('<br>')[2].split('<hr>')[0].strip
# 				startTime = exactStringSplit.split('–')[0].split(' ')[1..-1].join(' ')
# 				endTime   = exactStringSplit.split('–')[1].split(' ')[0..1].join(' ')
# 				exactStringSplit.split(',').each do |day|
# 					dayArray.push(day.split(' ')[0])
# 				end
# 			end