class PagesController < ApplicationController
  require 'net/https'
  require 'uri'
  require 'json'
  require 'time'

  def main
    accessKey = ENV['ACCESS_KEY']
    uri  = "https://api.bing.microsoft.com" #APIエンドポイント
    path = "/v7.0/news/search?mkt=ja-jp" #ニュース検索のURL

    uri = URI(uri + path)
    request = Net::HTTP::Get.new(uri)
    request['Ocp-Apim-Subscription-Key'] = accessKey
    @response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end
    hash = JSON.parse(@response.body)
    random_article = hash["value"].sample
    @title = random_article["name"]
    @description = random_article["description"]
    # 文末が。じゃない場合に...にする処理
    @provider_name = random_article["provider"][0]["name"]
    # providerのimageあるなしで分岐する処理
    if random_article["datePublished"] != nil
      parsed_date_published_at = Time.parse(random_article["datePublished"]).in_time_zone('Tokyo')
      @date_published_at = "#{parsed_date_published_at.month}月#{parsed_date_published_at.day}日#{parsed_date_published_at.hour}時#{parsed_date_published_at.min}分"
    else
      @date_published_at = ""
    end
    if random_article["image"] != nil
      @image_url = random_article["image"]["thumbnail"]["contentUrl"]
      @image_width = random_article["image"]["thumbnail"]["width"]
      @image_height = random_article["image"]["thumbnail"]["height"]
    else
      @image_url = "https://1.bp.blogspot.com/-D2I7Z7-HLGU/Xlyf7OYUi8I/AAAAAAABXq4/jZ0035aDGiE5dP3WiYhlSqhhMgGy8p7zACNcBGAsYHQ/s1600/no_image_square.jpg"
      @image_width = 250
      @image_height = 250
    end
  end
end
