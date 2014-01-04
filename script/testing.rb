list = if File.exists?('CourseTimingsSpring')
          File.open('CourseTimingsSpring') do|file|
            Marshal.load(file)
          end
        else
           0
        end
puts list["COSI 12B 1"].inspect