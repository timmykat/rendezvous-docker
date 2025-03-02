class Admin::FaqsController < AdminController
  
  def index
    @faqs = Admin::Faq.all
  end

  def new
    @faq = Admin::Faq.new
  end

  def create
    @faq = Admin::Faq.new(faq_params)
    if !@faq.save
      flash_alert_now 'There was a problem creating the FAQ.'
      flash_alert_now  @faq.errors.full_messages.to_sentence
      redirect_to new_admin_faq_path
    else
      flash_notice 'The FAQ was successfully created'
    end
  end

  def show
    @faq = Admin::Faq.find(params[:id])
  end

  def update
    @faq = Admin::Faq.find(params[:id])
    if !@faq.update(faq_params)
      flash_alert_now 'There was a problem updating the FAQ information'
      flash_alert_now  @faq.errors.full_messages.to_sentence
      render action: :edit
    else
      redirect_to admin_faq_path(@faq)
    end
  end

  private
    def faq_params
      params.require(:admin_faq).permit(
        :question, 
        :response
      )
    end
end
