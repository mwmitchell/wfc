var App = {
  
  init : function(){
    /* immediately update the friends list! */
    this.updateFriendsList("/friends?offset=0");
  },
  
  /*
    Accepts a path to the friends resource.
    Requests the friends resource,
    the updates the #friends
    element with the friends response.
  */
  updateFriendsList : function(path){
    var app = this;
    $.get(path, function(data){
      $("#friends").html(data);
      $(".friendsPaginationLink").click(function(){
        app.updateFriendsList($(this).attr("href"));
        return false;
      });
      $(".friendCommenterCountLink").click(function(){
        $('#friends').block({
          message: "loading comment data...",
          css: { padding : "1em", border : '#333' }
        });
        $("#friendcommentorcounts").fadeOut();
        var link = $(this);
        app.updateFriendCommentorCounts(link.attr("href"), function(){
          $(".friendCommenterCountLink.selected").removeClass("selected");
          link.addClass("selected");
          $("#friendcommentorcounts").fadeIn();
          $('#friends').unblock();
        });
        return false;
      });
    });
  },
  
  /*
    Requests the friend_commenter_counts resource
    and updates the #friendcommentorcounts element.
  */
  updateFriendCommentorCounts : function(path, callback){
    $.get(path, function(data){
      $("#friendcommentorcounts").html(data);
      callback();
    });
  }
  
}

/* on dom ready... */
$(function(){
  /* hide the main ajax load indicator image */
  $("#loading img").hide();

  /* show/hide the load indicator during Ajax requests */
  $(document).ajaxStart(function(){
    $("#loading img").show();
  }).
    ajaxStop(function(){
      $("#loading img").hide();
    });
});