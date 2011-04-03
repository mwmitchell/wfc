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
      pagination = friends.paging
      %W(previous next).each do |type|
        qparams = extract_query_params(pagination[type])
        if qparams.any?
          out << link_to(type, friends_path(:offset => qparams["offset"]),
            :class=>"friendsPaginationLink")
        else
          out << content_tag(:em, type)
        end
      end
    end
    out.join(" | ")
  end
  
  # Extracts the query params from a url
  # and returns them in Hash form.
  def extract_query_params url
    uri = (URI.parse(url).query rescue nil)
    uri ? Rack::Utils.parse_query(uri) : {}
  end
  
  # Accepts a "friends" array and a
  # single friend item from that array.
  # Returns a view, generated from
  # the _friend.html.haml partial.
  def render_friend_item_view(friends, friend)
    index = friends.index friend
    render("friend", {
      :friend => friend,
      :is_end => friend == friends.last,
      :is_last => ((index + 1) % 4 == 0)})
  end
  
end