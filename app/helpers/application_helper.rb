module ApplicationHelper

  # Returns a title for every page
  def title
    base_title = "Podil"
    if @title.nil?
      base_title
    else
      "#{@title}"
    end
  end
end
