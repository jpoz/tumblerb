require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module TumblrPostSpecHelper
  def mock_feed(n)
    xml = File.read(
      File.join( File.dirname(__FILE__), '../fixtures', "read.xml")
    )
  
    TumblrPost.should_receive(:open).at_least(n).times.and_return(xml)
  end
end

describe TumblrPost do
  include TumblrPostSpecHelper
  
  describe '#tumble' do

    before(:each) do
      mock_feed(1)
      @ps = {:start => 0, :num => 10}
      @posts = TumblrPost.tumble('account', @ps)
    end

    it "should populate the url-big" do
      @posts.each do |post|
        post.big_url.should_not be_blank
      end
    end

    it "should populate the small-url" do
      @posts.each do |post|
        post.small_url.should_not be_blank
      end
    end

    it "should populate the datetime" do
      @posts.each do |post|
        post.timestamp.should_not be_blank
      end
    end

    it "should populate the caption" do
      @posts.each do |post|
        post.text.should_not be_blank
      end
    end

    it "should return an array" do
      Array.should === @posts
    end 
    
    it "should populate the datetime" do
      TumblrPost.all.each do |post|
        post.post_datetime.should_not be_blank
      end
    end
    
    it "shouldn't add double posts" do
      lambda {
        TumblrPost.tumble('account', @ps)
      }.should change(TumblrPost, :count).by(0)
    end
    
  end
  
  describe "#check_and_get_tumblr" do
    it "should have specs" do
      pending
    end
  end
  
  describe "#find_or_new" do
    it "should find a TumblrPost" do
      TumblrPost.create(:text => "Yippidy yippidy do da")
      tumble = TumblrPost.find_or_new(:text => "Yippidy yippidy do da")
      tumble.new_record?.should be_false
    end
    
    it "should make a new TumblrPost if one does not exist" do
      tumble = TumblrPost.find_or_new(:text => "I eat a cheeze doodle")
      tumble.new_record?.should be_true
    end
    
  end
end
