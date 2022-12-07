class PrototypesController < ApplicationController
  before_action :move_to_toppage, only: [:new, :create, :edit, :update, :destroy]

  def index
    @prototypes = Prototype.all
  end

  def new
    @prototype = Prototype.new
  end

  def create
    @prototype = Prototype.new(new_prototype)
    if @prototype.save
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    @prototype = Prototype.find(params[:id])
    @comment = Comment.new
    @comments = @prototype.comments.includes(:user)
  end

  def edit
    @prototype = Prototype.find(params[:id])

    unless current_user.id == @prototype.user_id
      redirect_to action: :index
    end
  end

  def update
    prototype = Prototype.find(params[:id])
    prototype.update(new_prototype)

    if prototype.save
      redirect_to prototype_path(prototype)
    else
      prototype = Prototype.find(params[:id])
      redirect_to edit_prototype_path(prototype)
    end
  end

  def destroy
    prototype = Prototype.find(params[:id])
    prototype.destroy
    redirect_to root_path
  end

  private

  def new_prototype
    params.require(:prototype).permit(:title, :catch_copy, :concept, :image).merge(user_id: current_user.id)
  end

  def move_to_toppage
    unless user_signed_in?
      redirect_to root_path
    end
  end

end
