class Page < ApplicationRecord
  def self.time_diff_between_current_and_latest_news
    if Page.exists?
      latest_news = Page.all.order(date_published: "DESC").first
      time_diff_sec = Time.now - latest_news["date_published"]
      time_diff_hour = time_diff_sec / 3600
    else
      time_diff_hour = 3
    end
  end

  def self.random_page
    random_id = rand(Page.first.id..Page.last.id)
    Page.find(random_id)
  end

  def self.destroy_all_page
    if Page.exists?
      Page.destroy_all
    end
  end
end
