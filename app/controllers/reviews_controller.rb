class ReviewsController < ApplicationController
  before_action :set_review, only: [ :edit, :update, :destroy ]

  def create
    @list = List.find(params[:list_id])
    @review = @list.reviews.new(review_params)
    @review.user = current_user

    if @review.save
      redirect_to list_path(@list, anchor: "reviews"), notice: "Review published."
    else
      @bookmark = Bookmark.new
      render "lists/show", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      redirect_to list_path(@review.list, anchor: "reviews"), notice: "Review updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    list = @review.list
    @review.destroy
    redirect_to list_path(list, anchor: "reviews"), notice: "Review deleted.", status: :see_other
  end

  private

  def set_review
    @review = current_user.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(:content, :rating)
  end
end
