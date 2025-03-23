class FaqsController < AdminController
  before_action :require_admin, { except: :index } 
  
  def index
    @faqs = Faq.sorted
  end

  def new
    @faq = Faq.new
  end

  def create
    @faq = Faq.new(faq_params)
    if !@faq.save
      flash_alert_now 'There was a problem creating the FAQ.'
      flash_alert_now  @faq.errors.full_messages.to_sentence
      redirect_to new_faq_path
    else
      flash_notice 'The FAQ was successfully created'
    end
  end

  def update
    @faq = Faq.find(params[:id])
    if !@faq.update(faq_params)
      flash_alert_now 'There was a problem updating the FAQ information'
      flash_alert_now  @faq.errors.full_messages.to_sentence
      render action: :edit
    else
      @faqs = Faq.sorted
      redirect_to faqs_manage_path
    end
  end

  def manage
    @faqs = get_objects "Faq" 
  end

  def destroy
    @faq = Faq.find(params[:id])
    @faq.destroy
    redirect_to faqs_manage_path
  end

  def destroy_all
    Faq.destroy_all
    redirect_to faqs_manage_path
  end

  def import
    import_data "faqs.csv", "Faq"
    redirect_to faqs_manage_path
  end

  private
    def faq_params
      params.require(:faq).permit(
        :question, 
        :response
      )
    end
end
