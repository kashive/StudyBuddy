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
    var user_id = gon.logged_user['id'];
    var pusher = new Pusher('19d5c989143e4861ce3a');
    $(function() {
        // making sure that the chat is closed to begin with
        $('.chat').slideToggle(300, 'swing');
       //check if the user is signed in
       if (user_id !== undefined){
            var notificationChannel = pusher.subscribe('private-'+ user_id);
            var chatChannel = pusher.subscribe('presence-chat');
            var receivedChatChannel;
            notificationChannel.bind('notification', function(data) {
                number = Number($('sub').html());
                $.each(data['toShow'], function( k, v ) {
                    $(".notification").prepend("<li class = \"notification_list\"> <a class = \"notification_href\" href = \""+ v[0]+ "\">" + k + "</a></li> <div class= \"time_ago\">" + jQuery.timeago(v[1]) + " <b>Unseen</b> </div> <li class=\"divider\"></li>");
                    $('sub').html(number+1);
                });
            });
             // in the success callback get all the people that are currently subscribed to the chatChannel, iterate thorough then and check if they are a classmate and if they are then append the person's name, email and the classrelationship into the chat box
            chatChannel.bind('pusher:subscription_succeeded', function(members) {
              $.update_chat(user_id, members);
            });

            chatChannel.bind('pusher:member_added', function(member) {
              $.update_chat(user_id, chatChannel.members);              
            });

            chatChannel.bind('pusher:member_removed', function(member) {
              $.update_chat(user_id, chatChannel.members);
            }); 
            chatChannel.bind('client-join', function(data) {
                alert('client join chat trigter!!!');
              // subscribing to the same channel as the user who initiated the chat
              if (data[gon.logged_user['email']] !== undefined){
                receivedChatChannel = pusher.subscribe('private-' + gon.logged_user['email'] + data[gon.logged_user['email']]);
                receivedChatChannel.bind('pusher:subscription_succeeded',function(){
                    alert("subscribtiont by the receiving user also done");
                });
                receivedChatChannel.bind('pusher:subscription_error',function(status){
                    alert("subscribtiont by the receiving user error");
                });
              }
            });

            if (receivedChatChannel !== undefined){
                receivedChatChannel.bind('message',function(data){
                    // append the message into the chat window
                    alert(JSON.stringify(data));
                });
            }
       }
    });

    jQuery.update_chat = function(user_id,members){
        $("#number_online").html("(" + (members.count - 1) + ")");
          // get rid of all the names that are already there in the chat box
        $(".chat-history").empty();
        // add all the members who are a classmate, except the current user into the chat box
        members.each(function(member) {
            if (member.id == user_id){
                return true;
            }
            $.each(member.info["allClassmatesId"], function(k , v){
                if(k == user_id){
                    $(".chat-history").append("<div class= \"chat-message clearfix\"> <div class= \"chat-message-content clearfix\"> <h5 class = \"chatheader\">" + member.info["first_name"] + " " + member.info["last_name"] + " (" + member.info["email"] + ")" + "<br> <span class = \"class_name\">" + v[v.length - 1] + "</span></h5></div></div><hr>");
                }
            });
        });
    }

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

    // CHAT JQUERY
    $('#live-chat header').on('click', function() {
        $('.chat').slideToggle(300, 'swing');

    });

    $('.chat-history').on('mouseover','.chatheader',function(){
        $(this).css('cursor', 'pointer');
    });

    $('.chat-history').on('click','.chatheader',function(){
       // start a private channel with current user and the clicked user email addressess (take into account authentication)
            //for this user you can directly subscribe
            //but for the other user, send a message(two emails) to a custom binding and then the other user also joins that channel 
       // open a new chat box with the clicked user's name on title
       // var privateChatChannel = pusher.subscribe('private-'+ user_id);
       // extracting the email from the clicked chat name of format "(avishek@brandeis.edu)"
        var nameEmail = $(this).html().split('<br>')[0].split(' ');
        var email = (nameEmail[nameEmail.length - 1].replace('(','').replace(')',''));
        // subscribing to the private chat channel
        var privateChat = pusher.subscribe('private-'+ gon.logged_user['email'] + email);
        privateChat.bind('pusher:subscription_succeeded', function() {
            alert('yoyoyoy');
             pusher.channel('presence-chat').trigger('client-join', {email:gon.logged_user['email']});
        });

    });

    $('.chat-close').on('click', function(e) {
        e.preventDefault();
        $('#live-chat').fadeOut(300);
    });
});