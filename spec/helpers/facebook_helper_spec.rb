require 'spec_helper'

describe FacebookHelper do
  
  class MockView < ActionView::Base
    include FacebookHelper
  end
  
  before(:each) { @template = MockView.new }
  
  context "facebook_login_button" do
    
    before do
      @html = @template.facebook_login_button
      doc = Nokogiri::HTML(@html)
      @btn = doc.at("login-button")
    end
    
    it "should have a fb namespace" do
      @html.should match(/^<fb:login-button .+/)
    end
    
    it "should have the proper attributes" do
      @btn["autologoutlink"].should eq("true")
      @btn["id"].should eq("fb_login")
      @btn["onlogin"].should eq("location = \"/\"")
      @btn["perms"].should eq("user_likes, friends_likes, read_stream")
      @btn["size"].should eq("large")
    end
    
  end
  
end