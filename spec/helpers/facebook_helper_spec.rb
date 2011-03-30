require 'spec_helper'

describe FacebookHelper do
  
  context "facebook_login_button" do
    
    before do
      @html = helper.facebook_login_button
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
  
  context "friends_pagination" do
    
    context "no pagination in input" do
      it "should return an empty string" do
        friends = mock("friends")
        html = helper.friends_pagination friends
        html.should eq("")
      end
    end
    
    context "with pagination on input" do
      before do
        friends = mock("friends")
        friends.stub!(:paging)
        friends.should_receive(:paging).
          and_return({
            "previous" => "http://localhost?offset=0",
            "next" => "http://localhost?offset=2"
          })
        html = helper.friends_pagination friends
        @pagination = Nokogiri::HTML(html)
      end
      
      it "should contain next and previous links" do
        prev_link, next_link = @pagination.css("a.friendsPaginationLink")
        prev_link.text.should eq("previous")
        next_link.text.should eq("next")
        prev_link["href"].should eq(helper.friends_path(:offset => 0))
        next_link["href"].should eq(helper.friends_path(:offset => 2))
      end
      
    end
    
  end
  
  context "extract_query_params" do
    
    it "should extract the query params from a valid url string" do
      result = helper.extract_query_params("http://blah.com?id=1&name=xxx")
      result.keys.sort.should eq(["id", "name"])
      result["id"].should eq("1")
      result["name"].should eq("xxx")
    end
    
    it "should handle a bad url" do
      result = helper.extract_query_params("!asdfasdfasdf")
      result.should == {}
    end
    
    it "should handle a blank/nil input" do
      result = helper.extract_query_params(nil)
      result.should == {}
    end
    
  end
  
  context "render_friend_item_view" do
    
    before do
      @friends = [
        {"name" => "sam", "id" => "1", "picture" => "sam.jpg"},
        {"name" => "i", "id" => "2", "picture" => "i.jpg"},
        {"name" => "am", "id" => "3", "picture" => "am.jpg"},
        {"name" => "foo", "id" => "4", "picture" => "foo.jpg"},
        {"name" => "bar", "id" => "5", "picture" => "bar.jpg"}
      ]
      html = "<div id='tmp'>"
      @friends.each do |friend|
        html << helper.render_friend_item_view(@friends, friend)
      end
      html << "</div>"
      doc = Nokogiri::HTML(html)
      @html = doc.css("#tmp").first
    end
    
    it "should create the correct number of elements" do
      @html.css(".friendCommenterCountLink").size.should == @friends.size
    end
    
  end
  
end