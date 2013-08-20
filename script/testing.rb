list = if File.exists?('CoursesList')
          File.open('CoursesList') do|file|
            Marshal.load(file)
          end
        else
           0
        end
puts list["Psychology"].inspect