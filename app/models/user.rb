class User
  
  attr_reader :uid, :graph
  
  def self.init_from_token_and_uid token, uid
    @user = new(Koala::Facebook::GraphAPI.new(token), uid)
  end
  
  def initialize(graph, uid)
    @graph = graph
    @uid = uid
  end
  
  def likes
    @likes ||= graph.get_connections(uid, 'likes')
  end

  def likes_by_category
    @likes_by_category ||= likes.sort_by {|l| l['name']}.group_by {|l| l['category']}.sort
  end
  
  def feed(opts = {})
    graph.get_connections(uid, "feed", opts)
  end
  
  def friends(opts = {})
    connections(uid, "friends", opts)
  end
  
  def friend_feed(uid, opts = {})
    connections(uid, "feed", opts)
  end
  
  def user_photo(uid)
    graph.get_picture(uid)
  end
  
  def me
    @me ||= object("me")
  end
  
  # TODO: check out graph.get_objects
  
  def object(node, identifier, opts = {})
    graph.get_object(node, identifier, opts)
  end
  
  def connections(node, type, opts = {})
    graph.get_connections(node, type, opts)
  end
  
  # 
  # # %p= @user.graph.get_connections("me", "friends").inspect
  # 
  # # https://github.com/arsduo/koala/wiki/Koala-on-Rails
  # # https://graph.facebook.com/me/friends?access_token=2227470867|2.XbwQ_eD8jPzMXM_XDvu4rA__.3600.1300852800-1684455199|4bY9qLvkpHfuJ_QapeA2IQP6iqQ
  # # https://graph.facebook.com/me/feed?access_token=2227470867|2.XbwQ_eD8jPzMXM_XDvu4rA__.3600.1300852800-1684455199|4bY9qLvkpHfuJ_QapeA2IQP6iqQ
  # # https://graph.facebook.com/friend-id/feed?access_token=2227470867|2.XbwQ_eD8jPzMXM_XDvu4rA__.3600.1300852800-1684455199|4bY9qLvkpHfuJ_QapeA2IQP6iqQ&limit=1000
  # # http://developers.facebook.com/docs/api/realtime/
  # 
  # # show photo of each friend
  
end