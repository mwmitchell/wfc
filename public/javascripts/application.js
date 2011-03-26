$(function(){
  
  var App = {
    
    init : function(){
      this.updateFriendsList("/friends?offset=0");
    },
    
    updateFriendsList : function(path){
      var app = this;
      $.get(path, function(data){
        $("#friends").html(data);
        $("#friends .friendsPaginationLink").click(function(){
          app.updateFriendsList($(this).attr("href"));
          return false;
        });
        $("#friends a.friendCommenterCountLink").click(function(){
          app.updateFriendCommentorCounts($(this).attr("href"));
          return false;
        });
      });
    },
    
    updateFriendCommentorCounts : function(path){
      $.get(path, function(data){
        $("#friendCommentorCounts").html(data);
      })
    }
    
  }
  
  App.init();
  
})