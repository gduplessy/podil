# app/services/youtube_service.rb
class YoutubeService
    include HTTParty
    base_uri "https://www.googleapis.com/youtube/v3"
    default_timeout 10 # 10 second timeout for API requests

    def self.search(query)
      get("/search", query: {
        q: query,
        part: "snippet",
        type: "video",
        key: ENV["YOUTUBE_API_KEY"]
      })
    end
end
