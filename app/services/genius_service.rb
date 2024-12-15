# app/services/genius_service.rb
class GeniusService
    include HTTParty
    base_uri "https://api.genius.com"

    def self.search(query)
      get("/search", query: { q: query }, headers: {
        "Authorization" => "Bearer #{ENV['GENIUS_ACCESS_TOKEN']}"
      })
    end

    def self.get_lyrics(song_id)
      get("/songs/#{song_id}", headers: {
        "Authorization" => "Bearer #{ENV['GENIUS_ACCESS_TOKEN']}"
      })
    end
end
