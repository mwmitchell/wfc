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
    @friends = current_user.friends(:limit => 12, :offset => params[:offset], :fields => "name,id,picture")
    render :partial => "friends"
  end
  
  def friend_commenter_counts
    @friend = current_user.friend(params[:id])
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