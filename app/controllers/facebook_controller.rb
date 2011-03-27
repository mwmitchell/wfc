class FacebookController < ApplicationController

  before_filter :facebook_auth
  before_filter :require_login, :except => :login

  helper_method :logged_in?, :current_user
  
  def index
    begin
      @likes_by_category = current_user.likes_by_category
    rescue Koala::Facebook::APIError
      redirect_to :login
    end
  end
  
  def friends
    @friends = current_user.friends(:limit => 10, :offset => params[:offset], :fields => "name,id,picture")
    render :partial => "friends"
  end
  
  # [SELECT post_id FROM stream WHERE source_id = 'UID'] returns the user's wall posts (stories on their profile)
  
  # [SELECT post_id FROM stream WHERE source_id in (SELECT target_id FROM connection WHERE source_id = 'UID')] returns the visible stream of all of a user's connections (Thats why you get less post with this)
  
  # {
  # "friends" : "select uid1 from friend where uid2 = me()",
  # 
  # "q1" : "select post_id from stream where source_id in (select uid1 from #friends)",
  # 
  # cq : "select text,fromid,post_id from comment where post_id in (select post_id from #q1)"
  # }
  
  def friend_commenter_counts
    @friend_feed = current_user.graph.get_connections(params[:id], "feed", :limit => 100)
    render :partial => "friend_commenter_counts"
  end
  
  def login
    # ...
  end

  protected

    def logged_in?
      !!@user
    end

    def current_user
      @user
    end

    def require_login
      unless logged_in?
        redirect_to :action => :login
      end
    end

    def facebook_auth
      @oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY)
      if fb_user_info = @oauth.get_user_info_from_cookie(request.cookies)
        @user = User.init_from_token_and_uid(
          fb_user_info['access_token'],
          fb_user_info['uid'])
      end
    end
    
end