class SearchController < ApplicationController
  def results
    # Clear any existing flash messages
    flash.clear

    # Validate and sanitize query parameter
    query = params[:q]&.strip

    # Check if query is blank
    if query.blank?
      flash[:error] = "Please enter a search term."
      return render :results, status: :unprocessable_entity
    end

    # Validate query length
    if query.length > 200
      flash[:error] = "Search term is too long. Maximum 200 characters."
      return render :results, status: :unprocessable_entity
    end

    # Validate query doesn't contain dangerous characters
    if query.match?(/[<>\"']/)
      flash[:error] = "Invalid characters in search term."
      return render :results, status: :unprocessable_entity
    end

    begin
      # YouTube search
      youtube_results = YoutubeService.search(query)

      # Check if YouTube returned any results
      if youtube_results.nil? || youtube_results['items'].nil? || youtube_results['items'].empty?
        flash[:error] = "No videos found matching your search. Please try a different query."
        return render :results, status: :unprocessable_entity
      end

      first_video = youtube_results['items'].first
      @video_url = "https://www.youtube.com/embed/#{first_video['id']['videoId']}"

      # Last.fm metadata
      lastfm_results = LastfmService.get_track_info(
        first_video["snippet"]["channelTitle"],
        first_video["snippet"]["title"]
      )

      if lastfm_results.nil? || lastfm_results.empty? || !lastfm_results["track"]
        flash[:error] = "No songs found matching your search. Please try a different query."
        return render :results, status: :unprocessable_entity
      end

      @song_title = lastfm_results["track"]["name"]
      @artist_name = lastfm_results["track"]["artist"]["name"]
      @song_length = lastfm_results["track"]["duration"]

      # Build purchase links with URL encoding
      @purchase_links = {
        "Spotify" => "https://open.spotify.com/search/#{ERB::Util.url_encode("track:#{@song_title}")}",
        "Apple Music" => "https://music.apple.com/search?term=#{ERB::Util.url_encode(@song_title)}",
        "Tidal" => "https://tidal.com/search?q=#{ERB::Util.url_encode(@song_title)}",
        "Amazon Music" => "https://music.amazon.com/search?term=#{ERB::Util.url_encode(@song_title)}",
        "YouTube Music" => "https://music.youtube.com/search?q=#{ERB::Util.url_encode(@song_title)}",
        "Deezer" => "https://deezer.com/search/#{ERB::Util.url_encode(@song_title)}",
        "SoundCloud" => "https://soundcloud.com/search?q=#{ERB::Util.url_encode(@song_title)}",
        "Bandcamp" => "https://bandcamp.com/search?q=#{ERB::Util.url_encode(@song_title)}"
      }
    rescue => e
      Rails.logger.error("Search Error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      flash[:error] = "Unable to complete your search. Please try again later."
      return render :results, status: :unprocessable_entity
    end

    render "results"
  end

  def index
    # Add any index action logic here
  end
end
