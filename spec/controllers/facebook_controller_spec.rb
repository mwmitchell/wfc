require 'spec_helper'

describe FacebookController do
  
  # Sets up the proper vars and expectations for a
  # BAD login. A block is required, which is used for
  # additional expectations and (most importantly)
  # the call the controller action.
  # This method always checks that:
  #   @oauth is set
  #   @user is nil
  #   the response is NOT a success
  #   the response is a redirect to the :login action.
  def prepare_for_failed_login! &block
    my_cookies = {:a => :cookie}
    request.cookies.merge! my_cookies 
    @oauth = mock("oauth")
    Koala::Facebook::OAuth.should_receive(:new).
      with(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY).
        and_return(@oauth)
    @oauth.should_receive(:get_user_info_from_cookie).
      with(my_cookies).
        and_return(nil)
    yield
    User.should_not_receive(:init_from_token_and_uid)
    assigns[:oauth].should eq(@oauth)
    assigns[:user].should eq(nil)
    response.should redirect_to(:login)
    response.should_not be_succes
  end
  
  # Sets up the proper vars and expectations for a
  # GOOD login. A block is required, which is used for
  # additional expectations and (most importantly)
  # the call the controller action.
  # This method always checks that:
  #   @oauth is set
  #   @user is the correct object
  def prepare_for_successful_login! &block
    my_cookies = {:a => :cookie}
    request.cookies.merge! my_cookies 
    @oauth = mock("oauth")
    user_info = {'access_token' => "foo", 'uid' => "bar"}
    @user = mock("user")
    Koala::Facebook::OAuth.should_receive(:new).
      with(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY).
        and_return(@oauth)
    @oauth.should_receive(:get_user_info_from_cookie).
      with(my_cookies).
        and_return(user_info)
    User.should_receive(:init_from_token_and_uid).
      with(user_info["access_token"], user_info["uid"]).
        and_return(@user)
    yield
    assigns[:user].should eq(@user)
  end
  
  describe 'index with GET' do
    
    context "bad login" do
      
      before do
        prepare_for_failed_login! do
          get :index
        end
      end
      
      it "should not set the @likes_by_category on a failed login" do
        assigns[:likes_by_category].should be(nil)
      end
      
    end
    
    context "a valid login" do
      
      before do
        prepare_for_successful_login! do
          @likes = :my_likes!
          @user.should_receive(:likes_by_category).
            and_return(@likes)
          get :index
        end
      end
      
      it "should assign @likes_by_category" do
        assigns[:likes_by_category].should eq(@likes)
      end
      
    end
    
    context "a valid login, but an api error occurred!" do
      
      before do
        prepare_for_successful_login! do
          @user.should_receive(:likes_by_category).
            and_raise(Koala::Facebook::APIError)
          get :index
        end
      end
      
      it "should redirect to /login when an API error is raised" do
        response.should redirect_to(:login)
      end
      
    end
    
  end
  
  describe "friends with GET" do
    
    context "authorized" do
    
      before do
        prepare_for_successful_login! do
          my_params = {:offset => 10}
          @friends = mock("friends")
          @user.should_receive(:friends).
            with({:offset => my_params[:offset], :limit => 12, :fields => "name,id,picture"}).
              and_return(@friends)
          get :friends, my_params
        end
      end
    
      it "should set @friends to the expected value" do
        assigns[:friends].should == @friends
      end
      
      it "should render the proper views/templates" do
        response.should render_template("facebook/_friends")
        response.should render_template("facebook/_friend")
        response.should_not render_template("layouts/application")
      end
    
    end
    
    context "not authorized" do
      
      before do
        prepare_for_failed_login! do
          get :friends
        end
      end
      
      it "should redirect to the login action" do
        response.should redirect_to(:login)
      end
      
    end
    
  end
  
  describe "friend_commenter_counts with GET" do
    
    context "authorized" do
    
      before do
        prepare_for_successful_login! do
          my_params = {:id => 10}
          @friend = mock("friend")
          @friend_feed = mock("friend_feed")
          @user.should_receive(:object).
            with(my_params[:id]).
              and_return(@friend)
          @user.should_receive(:friend_feed).
            with(my_params[:id], :limit => 100).
              and_return(@friend_feed)
          get :friend_commenter_counts, my_params
        end
      end
      
      it "should set @friend/@friend_feed to the expected values" do
        assigns[:friend].should == @friend
        assigns[:friend_feed].should == @friend_feed
      end
      
      it "should render the proper views/templates" do
        response.should render_template("facebook/_friend_commenter_counts")
        response.should_not render_template("layouts/application")
      end
    
    end
    
    context "not authorized" do
      
      before do
        prepare_for_failed_login! do
          get :friend_commenter_counts
        end
      end
      
      it "should redirect to the login action" do
        response.should redirect_to(:login)
      end
      
    end
    
  end
  
  
end