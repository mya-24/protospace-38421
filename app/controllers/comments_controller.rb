class CommentsController < ApplicationController

  def create
    @prototype = Prototype.find(params[:prototype_id])
    @comment = Comment.new(new_comment)
    @comments = @prototype.comments
    
    if @comment.save
      redirect_to "/prototypes/#{@prototype.id}"
    else
      render "prototypes/show"
    end
  end

  private

  def new_comment
    params.require(:comment).permit(:content).merge(user_id: current_user.id, prototype_id: params[:prototype_id])
  end

end
