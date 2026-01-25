# app/services/lastfm_service.rb
class LastfmService
    include HTTParty
    base_uri "https://ws.audioscrobbler.com/2.0/"
    default_timeout 10 # 10 second timeout for API requests

    def self.get_track_info(artist, track)
      get("", query: {
        method: "track.getInfo",
        artist: artist,
        track: track,
        api_key: ENV["LASTFM_API_KEY"],
        format: "json"
      })
    end
end
