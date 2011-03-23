class PagesController < ApplicationController
  require 'rubygems'
  require 'youtube_g'
  require 'musix_match'
  require 'mbws'
  require 'last_fm'
  require 'twitter'
  require 'nokogiri'

  def home
    client   = YouTubeG::Client.new
    @youtube = client.videos_by(:tags => ['music'],:time => :today, :per_page => 4)
  end

  def contact
    @title = "Contact Us"
  end

  def about
    @title = "Who are we?"
  end

  def help
    @title = "Hop hop and away!"
  end

  def search
    @title    = "Results"
    search    = params['q']
    sansearch = CGI.escape(search)
    client    = YouTubeG::Client.new
    @youtube  = client.videos_by(:query => "#{search}", :page => 1, :per_page => 1)
    @msearch  = Search.music_hash
    lfm       = LastFM.new()
    @similar  = lfm.artist.getSimilar(:artist => search, :limit => 5)
    @simitr   = lfm.track.getSimilar(:track => 'tik tok', :artist => 'ke$ha', :limit => 5)
    @get      = Nokogiri::XML(open("http://api.chartlyrics.com/apiv1.asmx//SearchLyric?#{@title}&song=#{sansearch}"))
  end

end
