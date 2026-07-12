class ListsController < ApplicationController
  before_action :set_list, only: [ :show, :edit, :update, :destroy ]
  before_action :load_cover_images, only: [ :new, :edit ]

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
      load_cover_images
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to @list, notice: "Collection updated successfully."
    else
      load_cover_images
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
    params.require(:list).permit(:name, :photo, :selected_cover_payload)
  end

  def load_cover_images
    @cover_query = params[:cover_query].to_s.strip
    @cover_images = []
    return if @cover_query.blank?

    @cover_images = Pexels::Client.new.search_photos(query: @cover_query)
  rescue Pexels::Client::Error => e
    flash.now[:alert] = e.message
  end
end
