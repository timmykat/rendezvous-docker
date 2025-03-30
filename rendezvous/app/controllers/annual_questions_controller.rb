class AnnualQuestionsController < ApplicationController
  def new
    @annual_question = AnnualQuestion.new
  end

  def create
    @annual_question = AnnualQuestion.new(annual_question_params)
    if !@annual_question.update(annual_question_params)
      flash_alert "There was a problem creating the question"
    end
    redirect_to admin_dashboard_path
  end

  def update
    @annual_question = AnnualQuestion.find(params[:id])
    if !@annual_question.update(annual_question_params)
      flash_alert "There was a problem updating the question"
    end
    redirect_to admin_dashboard_path
  end

  def destroy
    @annual_question = AnnualQuestion.find(params[:id])
    @annual_question.destroy
    redirect_to admin_dashboard_path
  end

  private
    def annual_question_params
      params.require(:annual_question).permit(
        :year,
        :question
      )
    end
      
end
