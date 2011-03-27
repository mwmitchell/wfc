$(function(){
  
  var App = {
    
    init : function(){
      /* hide the main ajax load indicator image */
      $("#loading img").hide();

      /* show/hide the load indicator during Ajax requests */
      $(document).ajaxStart(function(){
        $("#loading img").show();
      }).
        ajaxStop(function(){
          $("#loading img").hide();
        });
      
      /* immediately update the friends list! */
      this.updateFriendsList("/friends?offset=0");
    },
    
    /*
      Accepts a path to the friends resource.
      Requests the friends resource,
      the updates the #friends
      element with the friends response.
      
      This function also prevents
      multiple requests and will
      alert a message if the user
      attempts to do so.
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
          if($(".friendCommenterCountLink.active").length > 0 ){
            alert("Please wait...");
            return false;
          }
          var link = $(this);
          link.addClass("active");
          app.updateFriendCommentorCounts(link.attr("href"), function(){
            $(".friendCommenterCountLink.selected").removeClass("selected");
            link.removeClass("active").addClass("selected");
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
  
  /* Start the app. */
  App.init();
  
})