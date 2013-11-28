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
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require_tree .
$(document).ready(function() {
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
            message:'<%= current_user.first_name + " " + current_user.last_name%> wants you to join Study Buddy'
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

   	if (document.cookie == "signed_in=1"){
		$("body").css("background-color","rgb(247, 246, 246)")
	}

	if (document.cookie == ""){
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
});