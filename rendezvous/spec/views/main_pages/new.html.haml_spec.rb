require 'rails_helper'

RSpec.describe "main_pages/new", type: :view do
  before(:each) do
    assign(:main_page, MainPage.new())
  end

  it "renders new main_page form" do
    render

    assert_select "form[action=?][method=?]", main_pages_path, "post" do
    end
  end
end
