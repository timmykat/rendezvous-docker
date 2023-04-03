require "rails_helper"

RSpec.describe MainPagesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/main_pages").to route_to("main_pages#index")
    end

    it "routes to #new" do
      expect(:get => "/main_pages/new").to route_to("main_pages#new")
    end

    it "routes to #show" do
      expect(:get => "/main_pages/1").to route_to("main_pages#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/main_pages/1/edit").to route_to("main_pages#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/main_pages").to route_to("main_pages#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/main_pages/1").to route_to("main_pages#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/main_pages/1").to route_to("main_pages#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/main_pages/1").to route_to("main_pages#destroy", :id => "1")
    end

  end
end
