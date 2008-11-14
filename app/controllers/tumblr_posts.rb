class TumblrPosts < Application
  # provides :xml, :yaml, :js

  def index
    @posts = TumblrPost.all
    display @posts
  end

  def show
    @post = TumblrPost.get(params[:id])
    raise NotFound unless @post
    display @post
  end

  def new
    only_provides :html
    @post = TumblrPost.new
    display @post
  end

  def edit
    only_provides :html
    @post = TumblrPost.get(params[:id])
    raise NotFound unless @post
    display @post
  end

  def create(post)
    @post = TumblrPost.new(post)
    if @post.save
      redirect resource(@post), :message => {:notice => "TumblrPost was successfully created"}
    else
      message[:error] = "TumblrPost failed to be created"
      render :new
    end
  end

  def update(id, post)
    @post = TumblrPost.get(id)
    raise NotFound unless @post
    if @post.update_attributes(post)
       redirect resource(@post)
    else
      display @post, :edit
    end
  end

  def destroy(id)
    @post = TumblrPost.get(id)
    raise NotFound unless @post
    if @post.destroy
      redirect resource(:posts)
    else
      raise InternalServerError
    end
  end

end # Posts
