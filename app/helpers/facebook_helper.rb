module FacebookHelper
  
  def facebook_login_button(size='large')
    content_tag("fb:login-button", nil , {
      :perms => 'user_likes, friends_likes, read_stream',
      :id => "fb_login",
      :autologoutlink => 'true',
      :size => size,
      :onlogin => 'location = "/"'})
  end
  
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
  
  def extract_query_params url
    return if url.blank?
    Rack::Utils.parse_query(URI.parse(url).query)
  end
  
  def comment_counts
    c = @friend_feed.inject({}) do |counts,item|
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