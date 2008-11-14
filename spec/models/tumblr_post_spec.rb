require File.join( File.dirname(__FILE__), '..', "spec_helper" )

module TumblrPostSpecHelper
  def mock_feed(n=1)
    xml = File.read(
      File.join( File.dirname(__FILE__), '../fixtures', "read.xml")
    )
    TumblrPost.should_receive(:open).at_least(n).times.and_return(xml)
  end
  
  def mock_feed_new(n=1)
    xml = File.read(
      File.join( File.dirname(__FILE__), '../fixtures', "new.xml")
    )
    TumblrPost.should_receive(:open).at_least(n).times.and_return(xml)
  end
end

describe TumblrPost do
  include TumblrPostSpecHelper
  
  describe '#tumble' do

    before(:each) do
      mock_feed
      @ps = {:start => 0, :num => 10}
      @posts = TumblrPost.tumble('account', @ps)
    end
    
    it "should populate the tumblr id" do
      @posts.first.tumblr_id.should == 45874031
    end

    it "should populate the url-big" do
      @posts.first.big_url.should == 'http://media.tumblr.com/1zcWg2WNicm68n52u15sbxtw_500.jpg'
    end

    it "should populate the small-url" do
      @posts.first.small_url.should == 'http://media.tumblr.com/1zcWg2WNicm68n52u15sbxtw_75sq.jpg'
    end

    it "should populate the datetime" do 
      # I hate time... timestamp.should == DateTime.parse(..) passes with single run, if all test run it fails
      datetime = DateTime.parse('Wed, 13 Aug 2008 17:22:07')
      @posts.first.timestamp.year.should == datetime.year
      @posts.first.timestamp.month.should == datetime.month
      @posts.first.timestamp.day.should == datetime.day
      @posts.first.timestamp.hour.should == datetime.hour
      @posts.first.timestamp.sec.should == datetime.sec
    end

    it "should populate the caption" do
      @posts.first.text.should == 'My office. Notice I&#8217;m the only one here&#8230; It&#8217;s been a long day.'
    end

    it "should return an array" do
      Array.should === @posts
    end 
    
    it "shouldn't add double posts" do
      lambda {
        TumblrPost.tumble('account', @ps)
      }.should change(TumblrPost, :count).by(0)
    end
    
  end
  
  describe "#tumble options" do
    
    before(:each) do
      TumblrPost.all.destroy!
    end
    
    it "should not save when :save is false" do
      mock_feed
      @ps = {:start => 0, :num => 10, :save => false}
      lambda {
        @posts = TumblrPost.tumble('account', @ps)
      }.should_not change(TumblrPost, :count)
    end
    
    it "should save when :save is true" do
      mock_feed
      @ps = {:start => 0, :num => 10, :save => true}
      lambda {
        @posts = TumblrPost.tumble('account', @ps)
      }.should change(TumblrPost, :count)
    end
  end
  
  describe "#check_and_get_tumblr" do
    it "should update the database if new posts have been made to the tumblr account" do
      mock_feed
      TumblrPost.tumble('account').first.destroy
      lambda {
        TumblrPost.check_tumblr('account')
      }.should change(TumblrPost, :count).by(1)
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
