class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]

  # GET /pictures
  def index
    @title = 'Photo Gallery'
    pictures = Picture.all
    @pictures_by_year = {}
    n = 0
    pictures.each do |pic|
      n += 1
      unless File.exist?(pic.image.gallery.path) && File.exist?(pic.image.display.path)
        pic.image.recreate_versions!(:gallery, :display)
        pic.save!
      end
      @pictures_by_year[pic.year] ||= []
      @pictures_by_year[pic.year] << pic
    end
    @pictures_by_year
  end
  
  # GET /my-pictures
  def my_pictures
    @title = 'My Photos'
    @pictures = current_user.pictures
  end
  
  # GET /pictures/1
  def show
  end

  # GET /pictures/new
  def new
    @picture = Picture.new
  end

  # GET /pictures/1/edit
  def edit
  end

  # POST /pictures
  def create
    @picture = Picture.new(picture_params)

    if @picture.save
      redirect_to @picture, notice: 'Picture was successfully created.'
    else
      render :new
    end
  end
  
  # POST /pictures/upload
  def upload
    params[:picture][:user_id] = current_user.id
    
    if params[:picture][:credit].blank?
      params[:picture][:credit] = current_user.display_name
    end
    
    if params[:picture][:caption].blank?
      params[:picture][:caption] = params[:picture][:image].original_filename
    end
    
    picture = Picture.new(picture_params)
    if picture.save
      respond_to do |format|
        format.html { render :partial => 'common/picture_form', :locals => { :pic => picture } }
        format.json { render :json => picture }
      end
    end
  end
      

  # PATCH/PUT /pictures/1
  def update
    if @picture.update(picture_params)
      respond_to do |format|
        format.json { render :json => { :status => :ok } }
      end
     end
  end

  # DELETE /pictures/1
  def destroy
    @picture.destroy
    redirect_to pictures_url, notice: 'Picture was successfully destroyed.'
  end
  
  # Recreate picture versions
  def recreate_versions
  end
  
  # Ajax delete
  def ajax_delete
    @picture = Picture.find(params[:id])
    @picture.destroy
    
    respond_to do |format|
      format.json { render :json => { status: 'ok' } }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_picture
      @picture = Picture.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def picture_params
      params.require(:picture).permit(:user, :image, :caption, :credit, :year, :user_id)
    end
end
