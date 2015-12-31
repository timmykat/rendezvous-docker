require 'rails_helper'

RSpec.describe "pictures/show", type: :view do
  before(:each) do
    @picture = assign(:picture, Picture.create!(
      :user => "",
      :image => "Image",
      :caption => "Caption",
      :credit => "Credit",
      :year => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Image/)
    expect(rendered).to match(/Caption/)
    expect(rendered).to match(/Credit/)
    expect(rendered).to match(/1/)
  end
end
