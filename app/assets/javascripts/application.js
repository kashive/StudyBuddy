// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery.min
//= require jquery_ujs
//= require jquery.ui.autocomplete
//= require twitter/bootstrap
//= require timeago
//= require_tree .


$(document).ready(function() {

    $(function() {
        var user_id = gon.logged_user['id'];
        var pusher = new Pusher('19d5c989143e4861ce3a'); // Replace with your app key
        var channel = pusher.subscribe('private-'+ user_id);

       channel.bind('notification', function(data) {
            number = Number($('sub').html());
            $.each(data['toShow'], function( k, v ) {
                $(".notification").prepend("<li class = \"notification_list\"> <a class = \"notification_href\" href = \""+ v[0]+ "\">" + k + "</a></li> <div class= \"time_ago\">" + jQuery.timeago(v[1]) + " <b>Unseen</b> </div> <li class=\"divider\"></li>");
                $('sub').html(number+1);
            });
        });
    });

    $('#fb_link').autocomplete({
        source: gon.locations
    });


	$('#fb_link').popover({
                  'selector': '',
                  'trigger':'hover',
                  'placement': 'bottom',
                  'container': 'body',
                  
    });

    $("a#invite_fb_friends").click(function(){
          FB.init({
            appId:'405059632873984',
            cookie:true,
            status:true,
            oauth: true,
          });

          FB.ui({
            method:'apprequests',
            message: gon.logged_user['first_name'] + " " + gon.logged_user['last_name'] + " wants you to join Study Buddy"
        });
    });

    if (($('.class_box').length)>5){
    	$('.bottom_class').css('display','none');
    	$('#class_pagination_right').css('display','inline');
    	$('#class_pagination_left').css('display','inline');
    };

    $('#class_pagination_right').click(function(){
    	$('.top_class').css('display','none');
    	$('.bottom_class').css('display','block');
    });

    $('#class_pagination_left').click(function(){
    	$('.bottom_class').css('display','none');
    	$('.top_class').css('display','block');
    });

    $('.icon-circle-arrow-left').mouseover(function(){
    	$(this).addClass("hover");
    });
    
    $('.icon-circle-arrow-left').mouseleave(function(){
    	$(this).removeClass("hover");
    });

    $('.icon-circle-arrow-right').mouseover(function(){
    	$(this).addClass("hover");
    });
    
    $('.icon-circle-arrow-right').mouseleave(function(){
    	$(this).removeClass("hover");
    });

    $('.class_box').mouseover(function(){
    	$(this).addClass("hover");
    });

    $('.class_box').mouseleave(function(){
    	$(this).removeClass("hover");
    });

    $('.class_box').click(function(){
    	return window.location = this.dataset.link;
    });

   	if (document.cookie.indexOf("signed_in=1") != -1){
		$("body").css("background-color","rgb(247, 246, 246)")
	}
	if (document.cookie.indexOf("signed_in=1") == -1){
		$("body").css("background-color","#5283B0")
	}
    // to make sure that the body color is blue if we are viewing the static pages
    if (window.location.pathname == "/static_pages/idea" || 
        window.location.pathname == "/static_pages/how"  ||
        window.location.pathname == "/static_pages/team" ||
        window.location.pathname == "/get_in_touches/new" ||
        window.location.pathname == "/static_pages/bugs"){
        $("body").css("background-color","#5283B0");
    }
    
    if (window.location.pathname.indexOf("/schedules/new") != -1){ 
        $('#table0').css('display','none');
        $('#table1').css('display','none');
    }

    $("#afternoon").click(function(){
        $('#table2').css('display','table');
        $('#table0').css('display','none');
        $('#table1').css('display','none');
    });

    $("#morning").click(function(){
        $('#table2').css('display','none');
        $('#table0').css('display','none');
        $('#table1').css('display','table');
    });
    $("#night").click(function(){
        $('#table2').css('display','none');
        $('#table0').css('display','table');
        $('#table1').css('display','none');
    });

    $(".notification_href").on("click",function() {
        var data = $(this).text() + ","+ $(this).attr('href');
        $.ajax({
            type: "PUT",
            url: "/notification_seen",
            dataType: "json",
            data: {"data":data},
        });
    });

    $(".red-box").click(function(){
        var myid = $(this).attr("id");
        var arr = myid.split('_');
        var toShowId = "green-box_" + arr[1] + "_" + arr[2];
        $("div#" + toShowId).css('display','inherit');
        $(this).css('display','none');
    });

    $(".green-box").click(function(){
        var myid = $(this).attr("id");
        var arr = myid.split('_');
        var toShowId = "white-box_" + arr[1] + "_" + arr[2];
        $("div#" + toShowId).css('display','inherit');
        $(this).css('display','none');
    });

    $(".white-box").click(function(){
        var myid = $(this).attr("id");
        var arr = myid.split('_');
        var toShowId = "red-box_" + arr[1] + "_" + arr[2];
        $("div#" + toShowId).css('display','inherit');
        $(this).css('display','none');
    });

    $("#invitation_select_all").click(function(){
        var checkBoxes = $('.invitation_checkboxes');
        checkBoxes.prop("checked", !checkBoxes.prop("checked"));
    });

    $("#submit_session").click(function(){
        // check if the none of the invitations are checked off
        if ($(".invitation_checkboxes:checked").length == 0){
            alert('You must invite atleast one classmate!!');
        }else{
            $('#new_study_session').submit();
        }
    });

    $("#generate_recommendation").click(function(){
        // collect all the checked off people and send it to the server
        // which then will do the computation and return back the text to render in the form
        var dataArray = new Array();
        // check if the none of the invitations are checked off
        if ($(".invitation_checkboxes:checked").length == 0){
            alert('You must invite atleast one classmate!!');
        }else{
            $('.invitation_checkboxes:checked').each(function(){
                dataArray.push($(this).attr('id'));
            });
            $.ajax({
                type: "PUT",
                url: "/getTimingRecommendation",
                dataType: "json",
                data: {"data":dataArray},
                success: function(data){
                    alert(JSON.stringify(data));
                    $('#time_recommendation').append("<strong>" +  JSON.stringify(data) + "</strong>");
                }
            });
        }
    });

    $("#schedule_update").click(function(){
        var dataArray = new Array();
        // get all div that have display inherit
        $(".red-box").filter(function() { return $(this).css("display") != "none" }).each(function(){
            dataArray.push($(this).attr("id"));
        });
        $(".green-box").filter(function() { return $(this).css("display") != "none" }).each(function(){
            dataArray.push($(this).attr("id"));
        });
        $(".white-box").filter(function() { return $(this).css("display") != "none" }).each(function(){
            dataArray.push($(this).attr("id"));
        });
        $.ajax({
            type: "PUT",
            url: "/update_schedule",
            dataType: "json",
            data: {"data":dataArray},
            success: function(data){
                location.reload();
            }
        });
    });
});