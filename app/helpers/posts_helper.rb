module PostsHelper

  def index 
    Post.all
  end

  def show
    Post.find(params[:id])
  end
end
