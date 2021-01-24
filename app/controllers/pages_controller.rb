class PagesController < ApplicationController
  require 'net/https'
  require 'uri'
  require 'json'
  require 'time'

  def main
    latest_news_in_db = Page.all.order(date_published: "DESC").first
    diff = Time.now - latest_news_in_db["date_published"]
    diff_converted_hour = diff / 3600
    # 現在の日時と最新のニュースの投稿日時の差が3時間あれば新しいニュースを取りに行く
    if diff_converted_hour >= 3
      # Bing News Search APIを叩く
      accessKey = ENV['ACCESS_KEY']
      uri  = "https://api.bing.microsoft.com"
      path = "/v7.0/news/search?mkt=ja-jp&freshness=day"
      uri = URI(uri + path)
      request = Net::HTTP::Get.new(uri)
      request['Ocp-Apim-Subscription-Key'] = accessKey
      @response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request(request)
      end
      # DBの中身を削除する(最新記事のみDBに保存されているようにしたい)
      if Page.exists?
        Page.destroy_all
      end
      # レスポンスを保存する
      article_array = JSON.parse(@response.body)["value"]
      article_array.each do |article|
        if article["image"] != nil
          image_url = article["image"]["thumbnail"]["contentUrl"]
          image_width = article["image"]["thumbnail"]["width"]
          image_height = article["image"]["thumbnail"]["height"]
        else
          image_url = "https://1.bp.blogspot.com/-D2I7Z7-HLGU/Xlyf7OYUi8I/AAAAAAABXq4/jZ0035aDGiE5dP3WiYhlSqhhMgGy8p7zACNcBGAsYHQ/s1600/no_image_square.jpg"
          image_width = 250
          image_height = 250
        end
        if article["datePublished"] != nil
          date_published = Time.iso8601(article["datePublished"])
        else
          date_published = ""
        end
        Page.create(name: article["name"], 
                    url: article["url"], 
                    image_url: image_url, 
                    image_width: image_width, 
                    image_height: image_height, 
                    description: article["description"], 
                    provider_name: article["provider"][0]["name"], 
                    date_published: date_published)
      end
      random_article = Page.where( 'id >= ?', rand(Page.first.id..Page.last.id) ).first
    else
      random_article = Page.where( 'id >= ?', rand(Page.first.id..Page.last.id) ).first
    end
    @title = random_article.name
    @description = random_article.description
    @provider_name = random_article.provider_name
    parsed_date_published = random_article.date_published.in_time_zone('Tokyo')
    @date_published = "#{parsed_date_published.month}月#{parsed_date_published.day}日#{parsed_date_published.hour}時#{parsed_date_published.min}分"
  end
end
