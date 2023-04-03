require 'rails_helper'

RSpec.describe "main_pages/show", type: :view do
  before(:each) do
    @main_page = assign(:main_page, MainPage.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
