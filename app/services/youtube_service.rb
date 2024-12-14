# app/services/youtube_service.rb
class YoutubeService
    include HTTParty
    base_uri 'https://www.googleapis.com/youtube/v3'
  
    def self.search(query)
      get("/search", query: { 
        q: query, 
        part: 'snippet', 
        type: 'video', 
        key: ENV['YOUTUBE_API_KEY']
      })
    end
  end