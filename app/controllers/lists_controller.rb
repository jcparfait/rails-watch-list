class ListsController < ApplicationController
  before_action :set_list, only: [ :show, :edit, :update, :destroy ]

  def index
    @lists = current_user.lists.includes(:movies).order(created_at: :desc)
  end

  def show
    @bookmark = Bookmark.new
  end

  def new
    @list = current_user.lists.new
  end

  def create
    @list = current_user.lists.new(list_params)

    if @list.save
      redirect_to @list, notice: "Collection created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: "Collection updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    redirect_to lists_path, notice: "Collection deleted.", status: :see_other
  end

  private

  def set_list
    @list = current_user.lists
                        .includes(bookmarks: { movie: { movie_reviews: :user } })
                        .find(params[:id])
  end

  def list_params
    params.require(:list).permit(:name, :photo)
  end
end
