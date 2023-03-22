require 'rails_helper'

RSpec.describe "pictures/index", type: :view do
  before(:each) do
    assign(:pictures, [
      Picture.create!(
        user: "",
        image: "Image",
        caption: "Caption",
        credit: "Credit",
        year: 1
      ),
      Picture.create!(
        user: "",
        image: "Image",
        caption: "Caption",
        credit: "Credit",
        year: 1
      )
    ])
  end

  it "renders a list of pictures" do
    render
    assert_select "tr>td", text: "".to_s, count: 2
    assert_select "tr>td", text: "Image".to_s, count: 2
    assert_select "tr>td", text: "Caption".to_s, count: 2
    assert_select "tr>td", text: "Credit".to_s, count: 2
    assert_select "tr>td", text: 1.to_s, count: 2
  end
end
