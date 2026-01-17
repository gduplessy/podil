# config/sitemap.rb
# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = ENV.fetch("SITEMAP_HOST", "https://podil.example.com")

# Set the directory where the sitemap files will be stored
SitemapGenerator::Sitemap.public_path = "public/"

# Set the sitemap filename
SitemapGenerator::Sitemap.sitemaps_path = ""

# Create a sitemap
SitemapGenerator::Sitemap.create do
  # Homepage - highest priority
  add root_path, priority: 1.0, changefreq: "weekly"

  # Add other static pages here as they are created
  # Example:
  # add about_path, priority: 0.7, changefreq: "monthly"
  # add contact_path, priority: 0.5, changefreq: "monthly"

  # Note: Search result pages (/search/results?q=...) are excluded
  # because they are dynamic and user-generated. Individual results
  # should be indexed when they appear in search engines naturally.
end
