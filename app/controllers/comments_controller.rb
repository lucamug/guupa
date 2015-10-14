class CommentsController < ApplicationController
  load_and_authorize_resource

  def index
  end
  
  def show
    if @comment.commentable_type == "Post"
      # It is a comment to a post, redirecting to show fo the post
      redirect_to post_url(@comment.commentable_id, :anchor => "comment_#{@comment.id}")
    else
      # This need to be handled better, when will be possible to add comments to
      # othe things...
      redirect_to root_path, :notice => "This comment cannot be shown"
    end
  end

  def edit
  end

  def create
    @comment.user_id = current_user_obj.id
    if @comment.save
      if @comment.from_action == "open"
        @comment.commentable.open
        history_comment = @comment.commentable.comments.new
        history_comment.user_id = current_user_obj.id
        history_comment.body = ":OPEN"
        history_comment.save
      end
      if @comment.from_action == "close"
        @comment.commentable.close
        history_comment = @comment.commentable.comments.new
        history_comment.user_id = current_user_obj.id
        history_comment.body = ":CLOSE"
        history_comment.save
      end
      if current_user_is_guest? and (not @comment.temporary_email.blank?)
        # User added the temporary email
        make_current_user_temporary(@comment.temporary_email)
      end
      if @comment.commentable_type == "Post"
        redirect_to post_url(@comment.commentable_id, :anchor => "comment_#{@comment.id}"), :notice => t('comment.created')
      else
        redirect_to root_path, :notice => "This comment cannot be shown"
      end
    else
      render "new"
    end
  end

  def update
    if @comment.update_attributes(params[:comment])
      if @comment.commentable_type == "Post"
        redirect_to post_url(@comment.commentable_id, :anchor => "comment_#{@comment.id}"), :notice => t('comment.updated')
      else
        redirect_to root_path, :notice => "This comment cannot be shown"
      end
    else
      render :action => "edit"
    end
  end

  def new
    @post = Post.find(params[:id])
    @comment = @post.comments.new
    @comment.from_action = params[:action]
    @comment.progress = @post.progress
    render "new"
  end

  def open
    new
  end

  def close
    new
  end

  def progress
    new
  end

  def destroy
    if @comment.user_id == current_user_obj.id
      @comment.status = "REMOVED_BY_USER"
    elsif
      @comment.status = "REMOVED_BY_OTHER"
    end
    @comment.save
    redirect_to :back, :notice => t(:removed)
  end
end

