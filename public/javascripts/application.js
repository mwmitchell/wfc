$(function(){
  
  $("#loading img").hide();
  
  $(document).ajaxStart(function(){
    $("#loading img").show();
  }).
  ajaxStop(function(){
    $("#loading img").hide();
  });
  
  var App = {
    
    init : function(){
      this.updateFriendsList("/friends?offset=0");
    },
    
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
            // alert("waiting...");
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
    
    updateFriendCommentorCounts : function(path, callback){
      $.get(path, function(data){
        $("#friendcommentorcounts").html(data);
        callback();
      });
    }
    
  }
  
  App.init();
  
})