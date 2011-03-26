module FacebookHelper
  
  def facebook_login_button(size='large')
    content_tag("fb:login-button", nil , {
      :perms => 'user_likes, friends_likes, read_stream',
      :id => "fb_login",
      :autologoutlink => 'true',
      :size => size,
      :onlogin => 'location = "/"'})
  end
  
  def friend_commenter_counts_link friend
    link_to(friend["name"], friend_commenter_counts_path(:id => friend["id"]),
      :class => "friendCommenterCountLink")
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
  
end