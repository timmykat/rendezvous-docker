class KeyedContentsController < ApplicationController
  before_action :require_admin

  def new
    @keyed_content = KeyedContent.new
  end

  def create
    @keyed_content = KeyedContent.new(content_params)
    if !@keyed_content.save
      flash_alert_now 'There was a problem creating the content.'
      flash_alert_now  @keyed_content.errors.full_messages.to_sentence
      redirect_to new_keyed_content_path
    else
      flash_notice 'The content was successfully created'
    end
  end

  def edit
    @keyed_content = KeyedContent.find(params[:id])
  end

  def update
    @keyed_content = KeyedContent.find(params[:id])
    if !@keyed_content.update(content_params)
      flash_alert_now 'There was a problem updating the content'
      flash_alert_now  @keyed_content.errors.full_messages.to_sentence
      render action: :edit
    else
      @keyed_contents = KeyedContent.all
      redirect_to keyed_contents_manage_path
    end
  end

  def manage
    @keyed_contents = KeyedContent.order(:key)
    missing_keys = KeyedContent.content_keys - @keyed_contents.map{ |c| c.key }
    
    unless missing_keys.empty?
      missing_keys.each do |key|
        new_content = KeyedContent.create(key: key)
        if !new_content.persisted?
          Rails.logger.error "The content was not saved"
        end
      end
      @keyed_contents = KeyedContent.order(:key)
    end

    @keyed_contents
  end

  def destroy
    @keyed_content = KeyedContent.find(params[:id])
    redirect_to keyed_contents_manage_path
  end

  def destroy_all
    KeyedContent.destroy_all
    redirect_to keyed_contents_manage_path
  end

  def import
    import_data "keyed_contents.csv", "KeyedContent"
    redirect_to keyed_contents_manage_path
  end

  private
    def content_params
      params.require(:keyed_content).permit(
        :key, 
        :content
      )
    end

end
