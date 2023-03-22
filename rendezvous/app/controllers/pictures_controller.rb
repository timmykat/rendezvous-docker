class PicturesController < ApplicationController
  before_action :set_picture, only: [:show, :edit, :update, :destroy]

  LINDA_EMAIL = "lindabrams@yahoo.com"

  # GET /pictures
  def index
    @title = 'Photo Gallery'
    pictures = Picture.where.not(year: 9999).order(year: :desc).all
    @pictures_by_year = {}
    pictures.each do |pic|
      unless File.exist?(pic.image.gallery.path) && File.exist?(pic.image.display.path)
        pic.image.recreate_versions!(:gallery, :display)
        pic.save!
      end
      @pictures_by_year[pic.year] ||= []
      @pictures_by_year[pic.year] << pic
    end
    @pictures_by_year
  end

  # GET /t-shirt-gallery
  def t_shirt_gallery
    @title = 'T-Shirt Gallery'
    @pictures = Picture.where(year: 9999).all
    if @pictures.empty?
      @pictures = initialize_tshirt_gallery_images
    end
    @pictures
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
        format.html { render partial: 'common/picture_form', locals: { pic: picture } }
        format.json { render json: picture }
      end
    end
  end

  def initialize_tshirt_gallery_images
    ImageUploader.enable_processing = true
    user = User.where(email: LINDA_EMAIL ).first
    Dir['./image_data/t-shirt-gallery/*.jpg'].each do |picture|
      uploader = ImageUploader.new(user, :picture)
      path = Pathname.new(File.absolute_path(picture))

      # Copy file to work area
      params[:picture] = {
        user_id: user.id,
        credit: "#{user.first_name} #{user.last_name}",
        caption: "ANOTHER t-shirt",
        year: 9999,
        image:  Pathname.new(path.basename)
      }

      new_picture = Picture.new(picture_params)

      File.open(path) do |f|
        new_picture.image = f
      end

      if !new_picture.save
        puts "Error saving "
      end
    end
    Picture.where(year: 9999).all
  end


  # PATCH/PUT /pictures/1
  def update
    if @picture.update(picture_params)
      respond_to do |format|
        format.json { render json: { status: :ok } }
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
      format.json { render json: { status: 'ok' } }
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
