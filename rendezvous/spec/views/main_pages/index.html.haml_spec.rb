require 'rails_helper'

RSpec.describe "main_pages/index", type: :view do
  before(:each) do
    assign(:main_pages, [
      MainPage.create!(),
      MainPage.create!()
    ])
  end

  it "renders a list of main_pages" do
    render
  end
end
