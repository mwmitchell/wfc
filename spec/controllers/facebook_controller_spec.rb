require 'spec_helper'

describe FacebookController do
  
  # Sets up the proper vars
  # and expectations for a
  # BAD login.
  def prepare_for_failed_login!
    my_cookies = {:a => :cookie}
    request.cookies.merge! my_cookies 
    @oauth = mock("oauth")
    Koala::Facebook::OAuth.should_receive(:new).
      with(FACEBOOK_APP_ID, FACEBOOK_SECRET_KEY).
        and_return(@oauth)
    @oauth.should_receive(:get_user_info_from_cookie).
      with(my_cookies).
        and_return(nil)
  end
  
  # Sets up the proper vars
  # and expectations for a
  # GOOD login.
  def prepare_for_successful_login!
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
    @likes = :my_likes!
  end
  
  describe 'index with GET' do
    
    context "bad login" do
      
      before do
        prepare_for_failed_login!
        get :index
      end
      
      it "should assign @oauth" do
        assigns[:oauth].should eq(@oauth)
      end
      
      it "should not set @user " do
        assigns[:user].should eq(nil)
      end
      
      it "should redirect to /login" do
        response.should redirect_to(:login)
      end
      
      it "should not set @likes_by_category" do
        assigns[:likes_by_category].should be(nil)
      end
      
    end
    
    context "a valid login" do
      
      before do
        prepare_for_successful_login!
        @user.should_receive(:likes_by_category).
          and_return(@likes)
        get :index
      end
      
      it "should assign @user" do
        assigns[:user].should eq(@user)
      end
      
      it "should assign @likes_by_category" do
        assigns[:likes_by_category].should eq(@likes)
      end
      
    end
    
    context "a valid login, but an api error occurred!" do
      
      before do
        prepare_for_successful_login!
        @user.should_receive(:likes_by_category).
          and_raise(Koala::Facebook::APIError)
        get :index
      end
      
      it "should redirect to /login when an API error is raised" do
        response.should redirect_to(:login)
      end
      
    end
    
  end
  
  describe "GET successful friends" do
    
    before do
      prepare_for_successful_login!
      my_params = {:offset => 10}
      @friends = [{"id" => "1", "name" => "sam"}, {"id" => "2", "name" => "iam"}]
      @user.should_receive(:friends).
        with({:offset => my_params[:offset], :limit => 12, :fields => "name,id,picture"}).
          and_return(@friends)
      get :friends, my_params
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
  
end