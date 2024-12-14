class SearchController < ApplicationController
  def results
    # Clear any existing flash messages
    flash.clear
    
    query = params[:q]
    
    # YouTube search
    youtube_results = YoutubeService.search(query)
    @video_url = "https://www.youtube.com/embed/#{youtube_results['items'].first['id']['videoId']}"

    # Last.fm metadata
    if query.present?
      begin
        lastfm_results = LastfmService.get_track_info(
          youtube_results['items'].first['snippet']['channelTitle'], 
          youtube_results['items'].first['snippet']['title']
        )
        
        if lastfm_results.nil? || lastfm_results.empty? || !lastfm_results['track']
          flash[:error] = "No songs found matching your search. Please try a different query."
          return render :results, status: :unprocessable_entity
        end

        @song_title = lastfm_results['track']['name']
        @artist_name = lastfm_results['track']['artist']['name']
        @song_length = lastfm_results['track']['duration']
      rescue => e
        Rails.logger.error("LastFM Error: #{e.message}")
        flash[:error] = "Unable to find the song on LastFM. Please try again later."
        return render :results, status: :unprocessable_entity
      end
    end 
  
   # @purchase_links = {
   #   "iTunes" => lastfm_results['track']['toptags']['tag'].first['url'],
   #   "Amazon Music" => lastfm_results['track']['toptags']['tag'].last['url']
   # }

    # Genius lyrics
    #genius_results = GeniusService.search("#{@artist_name} #{@song_title}")
    #song_id = genius_results['response']['hits'].first['result']['id']
    #lyrics_data = GeniusService.get_lyrics(song_id)
    #@lyrics = lyrics_data['response']['song']['lyrics']['plain']

    render 'results'
  end

  def index
    # Add any index action logic here
  end
end