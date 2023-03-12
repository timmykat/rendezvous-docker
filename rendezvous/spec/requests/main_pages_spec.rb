require 'rails_helper'

RSpec.describe "MainPages", type: :request do
  describe "GET /main_pages" do
    it "works! (now write some real specs)" do
      get main_pages_path
      expect(response).to have_http_status(200)
    end
  end
end
