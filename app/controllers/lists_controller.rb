class ListsController < ApplicationController
  HERO_VIDEO_ID = 7_719_822

  before_action :set_list, only: [ :show, :edit, :update, :destroy ]
  before_action :load_cover_images, only: [ :new, :edit ]

  def index
    @lists = current_user.lists.includes(:movies).order(created_at: :desc)
    @hero_video = fetch_hero_video
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
      redirect_to list_path(@list), notice: "Collection created successfully.", status: :see_other
    else
      load_cover_images
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @list.update(list_params)
      redirect_to list_path(@list), notice: "Collection updated successfully.", status: :see_other
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

  def fetch_hero_video
    Rails.cache.fetch("pexels/hero_video/#{HERO_VIDEO_ID}", expires_in: 12.hours) do
      Pexels::Client.new.video(HERO_VIDEO_ID)
    end
  rescue Pexels::Client::Error
    nil
  end
end
