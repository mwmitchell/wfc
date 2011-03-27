module FacebookHelper
  
  # Builds a fb:login-button element.
  def facebook_login_button(size='large')
    content_tag("fb:login-button", nil , {
      :perms => 'user_likes, friends_likes, read_stream',
      :id => "fb_login",
      :autologoutlink => 'true',
      :size => size,
      :onlogin => 'location = "/"'})
  end
  
  # Builds the previous and next links
  # for paginating through friends.
  def friends_pagination friends
    out = []
    if friends.respond_to? :paging
      %W(previous next).each do |type|
        if qparams = extract_query_params(friends.paging[type])
          out << link_to(type, friends_path(:offset => qparams["offset"]),
            :class=>"friendsPaginationLink")
        else
          out << content_tag(:em, type)
        end
      end
    end
    out.join(" || ")
  end
  
  # Extracts the query params from a url
  # and returns them in Hash form.
  def extract_query_params url
    return if url.blank?
    Rack::Utils.parse_query(URI.parse(url).query)
  end
  
  # Calculates the counts for a
  # @friends_feed set.
  # Returns an array of arrays,
  # where each sub-array
  # contains 2 items, the first being
  # a user-id, the second being a Hash,
  # containing :count and :name keys.
  def comment_counts friend_feed
    c = friend_feed.inject({}) do |counts,item|
      counts.tap do
        next unless item["comments"]
        item["comments"]["data"].each do |comment|
          uid, name = comment["from"]["id"], comment["from"]["name"]
          counts[uid] ||= {:count => 0, :name => name}
          counts[uid][:count] += 1
        end
      end
    end
    c.sort{|a,b| b[-1][:count] <=> a[-1][:count] }
  end
  
end