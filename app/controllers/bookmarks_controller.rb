class BookmarksController < ApplicationController
  before_action :set_bookmark, only: [ :edit, :update, :destroy ]

  def new
    @list = current_user.lists.find(params[:list_id])
    @bookmark = @list.bookmarks.new
  end

  def create
    @list = current_user.lists.find(params[:list_id])
    @bookmark = @list.bookmarks.new(bookmark_params)

    if @bookmark.save
      redirect_to list_path(@list), notice: "Movie added to your collection.", status: :see_other
    else
      @review = Review.new
      render "lists/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bookmark.update(bookmark_params.except(:movie_id))
      redirect_to list_path(@bookmark.list), notice: "Personal note updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    list = @bookmark.list
    @bookmark.destroy
    redirect_to list_path(list), notice: "Movie removed from the collection.", status: :see_other
  end

  private

  def set_bookmark
    @bookmark = Bookmark.joins(:list)
                        .where(lists: { user_id: current_user.id })
                        .find(params[:id])
  end

  def bookmark_params
    params.require(:bookmark).permit(:comment, :movie_id)
  end
end
