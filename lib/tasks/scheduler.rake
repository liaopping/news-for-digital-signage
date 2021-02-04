require 'net/https'
require 'uri'
require 'json'
require 'open-uri'
require 'time'

task :create_page => :environment do
  puts "Creating page..."
  # Bing News Search APIを叩く
  uri  = "https://api.bing.microsoft.com"
  path = "/v7.0/news/search?mkt=ja-jp&freshness=day"
  uri = URI(uri + path)
  request = Net::HTTP::Get.new(uri)
  request['Ocp-Apim-Subscription-Key'] = ENV['ACCESS_KEY']
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
      http.request(request)
  end
  # DBの中身を削除する(最新記事のみDBに保存されているようにしたい)
  Page.destroy_all_page
  # レスポンスの記事を全て配列に詰め、一つずつDBに保存していく
  article_array = JSON.parse(response.body)["value"]
  article_array.each do |article|
    # Nokogiriで記事のHTMLを取得
    nokogiri_url = Nokogiri::HTML(URI.open(article["url"], "User-Agent" => "Mozilla/5.0 CK={} (Windows NT 6.1; WOW64; Trident/7.0; rv:11.0) like Gecko"))
    image_src_array = []
    # imgタグを全て抽出し、src属性の値を全て配列に詰める
    nokogiri_url.search('//img').each do |element_in_url|
        if element_in_url.attributes["src"] != nil
            image_src_array << element_in_url.attributes["src"].value
        end
    end
    if image_src_array.size > 0
      # httpsと画像ファイルの拡張子を含むURLのみ配列に詰める
      https_image_array = image_src_array.select{ |x| x.match?(/(https?:\/\/.*\.(?:png|jpg|gif|jpeg|tiff|bmp|ico|cur|psd|svg|webp))/)}
      result_size, result_place, result_width, result_height = 0, 0, 0, 0
      # httpsを含むURLが一つ以上あれば、画像サイズ判定の処理に進む
      if https_image_array.size > 0
        https_image_array.each_with_index do |elt, idx|
          # image_size[width, height]
          begin
            image_size = FastImage.size(elt)
            if result_size < image_size[0] + image_size[1]
              result_size = image_size[0] + image_size[1]
              result_width = image_size[0]
              result_height = image_size[1]
              result_place = idx
            end
          rescue
            next
          end
        end
      end
    end
    if https_image_array != nil && https_image_array.size > 0
      image_url = https_image_array[result_place]
      image_width = result_width
      image_height = result_height
    elsif article["image"] != nil
      image_url = article["image"]["thumbnail"]["contentUrl"]
      image_width = article["image"]["thumbnail"]["width"]
      image_height = article["image"]["thumbnail"]["height"]
    else
      image_url = "https://1.bp.blogspot.com/-D2I7Z7-HLGU/Xlyf7OYUi8I/AAAAAAABXq4/jZ0035aDGiE5dP3WiYhlSqhhMgGy8p7zACNcBGAsYHQ/s1600/no_image_square.jpg"
      image_width = 400
      image_height = 400
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
  puts "done."
end