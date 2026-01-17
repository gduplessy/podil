# app/helpers/structured_data_helper.rb
module StructuredDataHelper
  # Generate WebSite schema with search action for homepage
  def website_schema
    {
      "@context": "https://schema.org",
      "@type": "WebSite",
      "name": "Podil",
      "description": "Discover and listen to music. Search for any song, watch videos, and find where to buy or stream.",
      "url": root_url,
      "potentialAction": {
        "@type": "SearchAction",
        "target": {
          "@type": "EntryPoint",
          "urlTemplate": "#{results_search_index_url}?q={search_term_string}"
        },
        "query-input": "required name=search_term_string"
      }
    }.to_json.html_safe
  end

  # Generate MusicRecording schema for song result pages
  def music_recording_schema(song_title:, artist_name:, duration: nil, video_url: nil)
    schema = {
      "@context": "https://schema.org",
      "@type": "MusicRecording",
      "name": song_title,
      "byArtist": {
        "@type": "MusicGroup",
        "name": artist_name
      }
    }

    # Add duration if available (expects ISO 8601 duration format, e.g., "PT3M45S")
    schema[:duration] = duration if duration.present?

    # Add video if available
    if video_url.present?
      schema[:video] = {
        "@type": "VideoObject",
        "name": "#{song_title} - #{artist_name}",
        "embedUrl": video_url,
        "thumbnailUrl": "https://img.youtube.com/vi/#{extract_youtube_id(video_url)}/maxresdefault.jpg"
      }
    end

    schema.to_json.html_safe
  end

  # Generate Organization schema for the website
  def organization_schema
    {
      "@context": "https://schema.org",
      "@type": "Organization",
      "name": "Podil",
      "url": root_url,
      "logo": "#{root_url}icon.png",
      "description": "Music discovery platform that helps you find, watch, and stream your favorite songs."
    }.to_json.html_safe
  end

  private

  # Extract YouTube video ID from embed URL
  def extract_youtube_id(embed_url)
    return nil unless embed_url.present?

    # Extract ID from URL like "https://www.youtube.com/embed/VIDEO_ID"
    match = embed_url.match(%r{/embed/([^?]+)})
    match ? match[1] : nil
  end
end
