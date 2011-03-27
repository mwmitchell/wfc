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
  
  def friends(opts = {})
    connections(uid, "friends", opts)
  end
  
  def friend_feed(uid, opts = {})
    connections(uid, "feed", opts)
  end
  
  # Shortcut to graph.get_object
  def object(node, opts = {})
    graph.get_object(node, opts)
  end
  
  # Shortcut to graph.get_connections
  def connections(node, type, opts = {})
    graph.get_connections(node, type, opts)
  end
  
end