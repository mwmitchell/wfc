class FacebookController < ApplicationController

  before_filter :facebook_auth
  before_filter :require_login, :except => :login

  helper_method :logged_in?, :current_user
  
  def index
    @likes_by_category = current_user.likes_by_category
  end
  
  def friends
    @friends = current_user.friends(:limit => 10, :offset => params[:offset])
    render :partial => "friends"
  end
  
  def friend_commenter_counts
    @friend_feed = current_user.graph.get_connections(params[:id], "feed", :limit => 500)
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
      fb_user_info = @oauth.get_user_info_from_cookie(request.cookies)
      if fb_user_info
        @user = User.init_from_token_and_uid(
          fb_user_info['access_token'],
          fb_user_info['uid'])
      end
    end
    
end