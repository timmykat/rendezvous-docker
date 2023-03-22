require 'rails_helper'

RSpec.describe "pictures/edit", type: :view do
  before(:each) do
    @picture = assign(:picture, Picture.create!(
      user: "",
      image: "MyString",
      caption: "MyString",
      credit: "MyString",
      year: 1
    ))
  end

  it "renders the edit picture form" do
    render

    assert_select "form[action=?][method=?]", picture_path(@picture), "post" do

      assert_select "input#picture_user[name=?]", "picture[user]"

      assert_select "input#picture_image[name=?]", "picture[image]"

      assert_select "input#picture_caption[name=?]", "picture[caption]"

      assert_select "input#picture_credit[name=?]", "picture[credit]"

      assert_select "input#picture_year[name=?]", "picture[year]"
    end
  end
end
