// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ($) ->
	$(document).ready ->
		$("#course_department").change ->
			$('#course_name').empty()
			selected_text = $( "#course_department option:selected" ).text()
			if selected_text != ""
				for course in Object.keys(gon.subjectHash[selected_text])
					# teacher = gon.subjectHash[selected_text][course]
					# teacher = teacher.substring(1,teacher.length - 1)
					courseName = Object.keys(gon.subjectHash[selected_text][course])[0]
					if course.charAt(course.length-1) == "1"
						course = course[0..(course.length-3)]
					$("#course_name").append($('<option></option>').val(course).html(course + " => " + courseName)) if course != ""
		$(document).on 'click', 'tr[data-link]', (evt) -> 
			window.location = this.dataset.link
		#$("table").delegate "td", "mouseover mouseleave", (e) ->
		#  if e.type is "mouseover"
		#    $(this).parent().addClass "hover"
		#    $("colgroup").eq($(this).index()).addClass "hover"
		#  else
		#    $(this).parent().removeClass "hover"
		#    $("colgroup").eq($(this).index()).removeClass "hover"
