list = if File.exists?('CourseListSpring')
          File.open('CourseListSpring') do|file|
            Marshal.load(file)
          end
        else
           0
        end
puts list["Economics"]["ECON 20A 1"].inspect