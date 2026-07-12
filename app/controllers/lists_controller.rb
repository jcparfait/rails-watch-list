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
    apply_selected_cover(@list)

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
    @list.assign_attributes(list_params)
    apply_selected_cover(@list)

    if @list.save
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
    params.require(:list).permit(:name, :photo)
  end

  def load_cover_images
    @cover_query = params[:cover_query].to_s.strip
    @cover_images = []
    return if @cover_query.blank?

    @cover_images = Pexels::Client.new.search_photos(query: @cover_query)
  rescue Pexels::Client::Error => e
    flash.now[:alert] = e.message
  end

  def apply_selected_cover(list)
    payload = params.dig(:list, :selected_cover_payload)
    return if payload.blank?

    cover = JSON.parse(payload).with_indifferent_access
    image_url = cover[:image_url].to_s
    source_url = cover[:source_url].to_s

    return unless cover[:provider].to_s == "Pexels"
    return unless image_url.start_with?("https://images.pexels.com/")
    return unless source_url.start_with?("https://www.pexels.com/")

    list.assign_attributes(
      cover_image_url: image_url,
      cover_image_author: cover[:author].to_s,
      cover_image_author_url: cover[:author_url].to_s,
      cover_image_source_url: source_url,
      cover_image_provider: "Pexels",
      cover_image_alt: cover[:alt].to_s,
      cover_image_color: cover[:color].to_s
    )
  rescue JSON::ParserError
    nil
  end
end
