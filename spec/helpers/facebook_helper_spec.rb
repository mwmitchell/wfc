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
    
    def build_pagination pagination_params = nil
      friends = mock("friends")
      if pagination_params
        friends.stub!(:paging)
        friends.should_receive(:paging).
          and_return(pagination_params)
      end
      Nokogiri::HTML(helper.friends_pagination(friends))
    end
    
    context "no pagination in input" do
      it "should return an empty string" do
        html = build_pagination
        html.css("body").should be_empty
      end
    end
    
    context "with next/prev pagination on input" do
      before do
        pagination = build_pagination({
          "previous" => friends_path(:offset => 0),
          "next" => friends_path(:offset => 2)
        })
        @prev_link, @next_link = pagination.css("a.friendsPaginationLink")
      end
      
      it "should contain the expected previous text/href" do
        @prev_link.text.should eq("previous")
        @prev_link["href"].should eq(helper.friends_path(:offset => 0))
      end
      
      it "should contain the expected next text/href" do
        @next_link.text.should eq("next")
        @next_link["href"].should eq(helper.friends_path(:offset => 2))
      end
    end
    
    context "with next input only" do
      before do
        @pagination = build_pagination({
          "next" => friends_path(:offset => 2)
        })
      end
      
      it "should contain the expected next link" do
        links = @pagination.css("a.friendsPaginationLink")
        links.size.should == 1
        next_link = links.first
        next_link.text.should eq("next")
        next_link["href"].should eq(helper.friends_path(:offset => 2))
      end
      
      it "should contain the expected previous em tag" do
        ems = @pagination.css("em")
        ems.size.should == 1
        ems.first.text.should == "previous"
      end
    end
    
    context "with previous input only" do
      before do
        @pagination = build_pagination({
          "previous" => friends_path(:offset => 0)
        })
      end
      
      it "should contain the expected previous link" do
        links = @pagination.css("a.friendsPaginationLink")
        links.size.should == 1
        prev_link = links.first
        prev_link.text.should eq("previous")
        prev_link["href"].should eq(helper.friends_path(:offset => 0))
      end
      
      it "should contain the expected next em tag" do
        ems = @pagination.css("em")
        ems.size.should == 1
        ems.first.text.should == "next"
      end
    end
    
    context "should be OK with bad urls" do
      before do
        @pagination = build_pagination({
          "previous" => "--",
          "next" => "--"
        })
      end
      
      it "should contain the expected next/prev em tags" do
        ems = @pagination.css("em")
        ems.size.should == 2
        ems.first.text.should == "previous"
        ems.last.text.should == "next"
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