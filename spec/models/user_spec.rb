require 'spec_helper'

describe User do
  
  describe "init_from_token_and_uid" do
    it "should call :new with the proper args" do
      token, uid = "my-token", "my-uid"
      User.should_receive(:new).
        with(instance_of(Koala::Facebook::GraphAPI), uid).once
      User.init_from_token_and_uid(token, uid)
    end
  end
  
  describe "#connections" do
    
    before do
      @user = User.new(mock("graph api"), "my-uid")
    end
    
    it "should call graph.get_connections" do
      node, type, opts = "123", "friends", {:limit => 1}
      @user.graph.should_receive(:get_connections).
        with(node, type, opts)
      @user.connections(node, type, opts)
    end
    
    describe "friends" do
      it "should call connections with the proper args" do
        opts = {:limit => 1}
        @user.should_receive(:connections).
          with(@user.uid, "friends", opts)
        @user.friends(opts)
      end
    end
    
    describe "friend_feed" do
      
      it "should call connections with the proper args" do
        uid, opts = "123", {:abc => :def}
        @user.should_receive(:connections).
          with(uid, "feed", opts).
            and_return({})
        result = @user.friend_feed(uid, opts)
        result.should be_a(User::CountableFeedComments)
      end
      
      it "should produce comment/user counts" do
        feed_items = [
          {
            "comments" => {
              "data" => [
                {"from" => {"name" => "foaf-1", "id" => 1}},
                {"from" => {"name" => "foaf-2", "id" => 2}},
                {"from" => {"name" => "foaf-1", "id" => 1}}
              ]
            }
          },
          {
            "comments" => {
              "data" => [
                {"from" => {"name" => "foaf-1", "id" => 1}},
                {"from" => {"name" => "foaf-2", "id" => 2}},
                {"from" => {"name" => "foaf-3", "id" => 3}},
                {"from" => {"name" => "foaf-1", "id" => 1}},
                {"from" => {"name" => "foaf-1", "id" => 1}}
              ]
            }
          },
          {
            "comments" => {
              "data" => nil
            }
          },
          {
            "no-comments-here" => nil
          }
        ]
        @user.should_receive(:connections).
          and_return(feed_items)
        result = @user.friend_feed("123", {})
        result.should be_a(User::CountableFeedComments)
        result.should eq(feed_items)
        counts = result.comment_counts
        expected_counts = [
          [1, {:count=>5, :name=>"foaf-1"}],
          [2, {:count=>2, :name=>"foaf-2"}],
          [3, {:count=>1, :name=>"foaf-3"}]
        ]
        counts.should eq(expected_counts)
      end
    end
  end
  
  describe 'retrieving likes' do
    before do
      @graph = mock('graph api')
      @uid = 42
      @user = User.new(@graph, @uid)
      @likes = [
        {
          "name" => "The Office",
          "category" => "Tv show",
          "id" => "6092929747",
          "created_time" => "2010-05-02T14:07:10+0000"
        },
        {
          "name" => "Flight of the Conchords",
          "category" => "Tv show",
          "id" => "7585969235",
          "created_time" => "2010-08-22T06:33:56+0000"
        },
        {
          "name" => "Wildfire Interactive, Inc.",
          "category" => "Product/service",
          "id" => "36245452776",
          "created_time" => "2010-06-03T18:35:54+0000"
        },
        {
          "name" => "Facebook Platform",
          "category" => "Product/service",
          "id" => "19292868552",
          "created_time" => "2010-05-02T14:07:10+0000"
        },
        {
          "name" => "Twitter",
          "category" => "Product/service",
          "id" => "20865246992",
          "created_time" => "2010-05-02T14:07:10+0000"
        }
      ]
      @graph.should_receive(:get_connections).with(@uid, 'likes').once.and_return(@likes)
    end
    
    describe '#likes' do
      it 'should retrieve the likes via the graph api' do
        @user.likes.should == @likes
      end

      it 'should memoize the result after the first call' do
        likes1 = @user.likes
        likes2 = @user.likes
        likes2.should equal(likes1)
      end
    end

    describe '#likes_by_category' do
      it 'should group by category and sort categories and names' do
        @user.likes_by_category.should == [
          ["Product/service", [
            {
              "name" => "Facebook Platform",
              "category" => "Product/service",
              "id" => "19292868552",
              "created_time" => "2010-05-02T14:07:10+0000"
            },
            {
              "name" => "Twitter",
              "category" => "Product/service",
              "id" => "20865246992",
              "created_time" => "2010-05-02T14:07:10+0000"
            },
            {
              "name" => "Wildfire Interactive, Inc.",
              "category" => "Product/service",
              "id" => "36245452776",
              "created_time" => "2010-06-03T18:35:54+0000"
            }
          ]],
          ["Tv show", [
            {
              "name" => "Flight of the Conchords",
              "category" => "Tv show",
              "id" => "7585969235",
              "created_time" => "2010-08-22T06:33:56+0000"
            },
            {
              "name" => "The Office",
              "category" => "Tv show",
              "id" => "6092929747",
              "created_time" => "2010-05-02T14:07:10+0000"
            }
          ]]
        ]
      end
    end
  end
end