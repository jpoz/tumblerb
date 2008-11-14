require 'hpricot'
require 'open-uri'
require 'cgi'
require 'time'

class TumblrPost
  include DataMapper::Resource

  property :id, Serial
  property :tumblr_id, Integer
  property :big_url, String
  property :med_url, String
  property :small_url, String
  property :timestamp, DateTime
  property :text, Text
  property :post_type, String

  #has, n :comments
  
  def self.find_or_new(search_attributes, create_attributes = {})
    first(search_attributes) || new(search_attributes.merge(create_attributes))
  end

  def self.check_and_get_tumblr(acct)
    tumble_posts = self.tumble(acct, :start => 0, :num => 1 )
    post = find_or_new(:tumblr_id => tumble_posts[0]['id'])

    if post.new_record?
      tumble(acct, :start => 0, :num => 15, :save => true )
    end
    
    get(:all, :limit => 15, :order => "post_datetime DESC")
  end

  def self.tumble(acct, options = {})
    url = "http://#{acct}.tumblr.com/api/read?start=#{options[:start]}&num=#{options[:num]}"
    doc = Hpricot.XML(open(url))

    @posts= []
    current = options[:start]

    (doc/"post").each do |tumble_post|
      post = find_or_new(:tumblr_id => tumble_post["id"], :timestamp => Time.parse(tumble_post["date"]), :post_type => tumble_post['type'])
      if post.new_record?
        if post.post_type == "photo"
          extract_photo(tumble_post, post)
        end
        
        # begin
        #   TumblrPost.send("extract_#{post.post_type}", post)
        # rescue
        #   post.text = "Post type: #{post.post_type} is not supported yet... Why don't you add you lazy @#$"
        # end
        
        post.save if options[:save]
      end
      
      @posts << post
      current += 1
    end

    @posts
  end

  private

  def self.extract_photo(p, post = TumblrPost.new)
    post.big_url = (p/"photo-url").first.inner_html unless (p/"photo-url").first == nil
    post.med_url = post.big_url.to_s.gsub(/_500/, '_400')
    post.small_url = post.big_url.to_s.gsub(/_500/, '_75sq')
    post.text = CGI::unescapeHTML((p/"photo-caption").first.inner_html.to_s) unless (p/"photo-caption").first == nil
  end

  #### To-do: build other post types

end
