class PagesController < ApplicationController
  def index
    # @pages = Page.all
  end

  def create
    #
  end

  def show
    @random_article = Page.random_page
  end
end
