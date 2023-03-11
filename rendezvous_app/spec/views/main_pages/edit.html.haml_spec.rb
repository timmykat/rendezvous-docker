require 'rails_helper'

RSpec.describe "main_pages/edit", type: :view do
  before(:each) do
    @main_page = assign(:main_page, MainPage.create!())
  end

  it "renders the edit main_page form" do
    render

    assert_select "form[action=?][method=?]", main_page_path(@main_page), "post" do
    end
  end
end
