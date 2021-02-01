class PagesController < ApplicationController
  after_action :allow_iframe, only: [:show]
  def index
    # @pages = Page.all
  end

  def show
    @random_article = Page.random_page
  end

  private
    def allow_iframe
        url = "https://web-digital-signage.vercel.app"
        response.headers['X-Frame-Options'] = "ALLOW-FROM #{url}"
        response.headers['Content-Security-Policy'] = "frame-ancestors #{url}"
    end
end
