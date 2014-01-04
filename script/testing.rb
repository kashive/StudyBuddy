list = if File.exists?('CourseTimingsSpring')
          File.open('CourseTimingsSpring') do|file|
            Marshal.load(file)
          end
        else
           0
        end
puts list["ECON 80A 1"].inspect