class FacebookController < ApplicationController

  before_filter :facebook_auth
  before_filter :require_login, :except => :login
  
  helper_method :logged_in?, :current_user
  
  # The main action, which renders the index view.
  # Redirects to the login page if a
  # Koala::Facebook::APIError was raised.
  def index
    begin
      @likes_by_category = current_user.likes_by_category
    rescue Koala::Facebook::APIError
      redirect_to :login
    end
  end
  
  # Renders a list of friends, belonging to the +current_user+.
  # An optional :offset param can be given.
  # Produces a @friends var.
  def friends
    @friends = current_user.friends(:limit => 12, :offset => params[:offset], :fields => "name,id,picture")
    render :partial => "friends"
  end
  
  # Renders a list of commenter counts and names.
  # The params[:id] value is required.
  # Produces a @friend and @friend_feed var.
  def friend_commenter_counts
    uid = params[:id]
    raise "id param missing" if uid.blank?
    @friend = current_user.object(uid)
    @friend_feed = current_user.friend_feed(uid, :limit => 100)
    render :partial => "friend_commenter_counts"
  end
  
  # Render the login view.
  def login
    # ...
  end
  
  protected
    
    # Returns true if the @user var is truthy.
    # - Exposed as a helper method.
    def logged_in?
      !!@user
    end
  
    # Returns the @user var.
    # - Exposed as a helper method.
    def current_user
      @user
    end
  
    # Redirects to login action if the @user doesn't exist.
    # - Called as a before_filter
    def require_login
      unless logged_in?
        redirect_to :action => :login
      end
    end
  
    # Sets up the @user var if authentication is successful.
    # - Called as a before_filter
    def facebook_auth
      @oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY)
      if fb_user_info = @oauth.get_user_info_from_cookie(request.cookies)
        @user = User.init_from_token_and_uid(
          fb_user_info['access_token'],
          fb_user_info['uid'])
      end
    end

end