require 'spec_helper'

describe FacebookController do
  
  describe 'index with GET' do
    
    before do
      @user = User.new(mock('graph'), 42)
      @oauth = mock('oauth')
      @graph = mock('graph')
      Koala::Facebook::OAuth.should_receive(:new).and_return(@oauth)
    end
    
    context 'when logged into facebook' do
      
      before do
        user_info = {'access_token' => '1234567890', 'uid' => 42}
        @oauth.should_receive(:get_user_info_from_cookie).and_return(user_info)
        Koala::Facebook::GraphAPI.should_receive(:new).with('1234567890').and_return(@graph)
        User.should_receive(:new).and_return(@user)
        @likes = mock('likes')
        @user.should_receive(:likes_by_category).and_return(@likes)
      end
      
      it "should be a winning success!" do
        get :index
        response.should be_success
      end
      
      it 'should assign likes' do
        get :index
        assigns[:likes_by_category].should == @likes
      end
      
    end
    
    context "Koala::Facebook::APIError raised" do
      it "should redirect to the login" do
        user_info = {'access_token' => '1234567890', 'uid' => 42}
        @oauth.should_receive(:get_user_info_from_cookie).and_return(user_info)
        Koala::Facebook::GraphAPI.should_receive(:new).with('1234567890').and_return(@graph)
        User.should_receive(:new).and_return(@user)
        @likes = mock('likes')
        @user.should_receive(:likes_by_category).and_raise(Koala::Facebook::APIError)
        get :index
        response.should redirect_to(:login)
      end
    end

    context 'when not logged into facebook' do
      
      before do
        @oauth.should_receive(:get_user_info_from_cookie).and_return(nil)
        get :index
      end
      
      it 'should redirect to the login page' do
        response.should redirect_to(:action => :login)
      end
    end
    
  end

  describe 'login with GET' do
    
    before do
      get :login
    end
    
    it "should be a success" do
      response.should be_success
    end
    
  end
  
  describe "friends with GET" do
    before do
      @user = User.new(mock('graph'), 42)
      @oauth = mock('oauth')
      @graph = mock('graph')
      Koala::Facebook::OAuth.should_receive(:new).and_return(@oauth)
      user_info = {'access_token' => '1234567890', 'uid' => 42}
      @oauth.should_receive(:get_user_info_from_cookie).and_return(user_info)
      Koala::Facebook::GraphAPI.should_receive(:new).with('1234567890').and_return(@graph)
      User.should_receive(:new).and_return(@user)
    end
    
    it "should render using the expected views" do
      opts = {:offset => 10}
      friends = [{"id" => "1", "name" => "sam"}, {"id" => "2", "name" => "iam"}]
      @user.should_receive(:friends).
        with(opts.merge(:limit => 12, :fields => "name,id,picture")).
          and_return(friends)
      @params = opts
      get :friends, opts
      assigns[:friends].should == friends
      response.should render_template("facebook/_friends")
      response.should render_template("facebook/_friend")
      response.should_not render_template("layouts/application")
    end
    
  end
  
end