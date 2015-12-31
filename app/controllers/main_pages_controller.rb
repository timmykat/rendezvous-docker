class MainPagesController < ApplicationController
  before_action :set_main_page, only: [:show, :edit, :update, :destroy]

  # GET /
  def index
    @pictures = Picture.front_page_set
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_main_page
      @main_page = MainPage.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def main_page_params
      params[:main_page]
    end
end
