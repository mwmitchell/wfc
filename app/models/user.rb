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
    @likes_by_category ||= likes.sort_by {|l| l['name']}.group_by {|l| l['category'] }.sort
  end
  
  def friends(opts = {})
    connections(uid, "friends", opts)
  end
  
  # Returns a feed Hash,
  # which has been extended
  # with CountableFeedComments.
  def friend_feed(uid, opts = {})
    feed = connections(uid, "feed", opts)
    feed.extend CountableFeedComments
  end
  
  # Shortcut to graph.get_object
  def object(node, opts = {})
    graph.get_object(node, opts)
  end
  
  # Shortcut to graph.get_connections
  def connections(node, type, opts = {})
    graph.get_connections(node, type, opts)
  end
  
  module CountableFeedComments
    
    # Calculates the counts for a feed set.
    # Returns an array of arrays,
    # where each sub-array
    # contains 2 items, the first being
    # a user-id, the second being a Hash,
    # containing :count and :name keys.
    def comment_counts
      @comment_counts ||= (
        counts = {}
        self.each { |item|
          next if item["comments"].blank? || item["comments"]["data"].blank?
          item["comments"]["data"].each do |comment|
            uid, name = comment["from"]["id"], comment["from"]["name"]
            counts[uid] ||= {:count => 0, :name => name}
            counts[uid][:count] += 1
          end
        }
        counts.sort{|a,b| b[-1][:count] <=> a[-1][:count] }
      )
    end
  end
  
end