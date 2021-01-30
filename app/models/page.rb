class Page < ApplicationRecord
  def self.time_diff_between_current_and_latest_news
    if self.exists?
      latest_news = self.order(date_published: "DESC").first
      time_diff_sec = Time.now - latest_news["date_published"]
      time_diff_hour = time_diff_sec / 3600
    else
      time_diff_hour = 3
    end
  end
end
